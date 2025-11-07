"""Zabbix Cloud API client (JSON-RPC) minimal wrapper.

Usage:
	from app.zabbix_client import ZabbixClient
	client = ZabbixClient(base_url, api_token=...) or (user, password)
	triggers = client.get_active_triggers()

Environment variables recommended:
	ZABBIX_URL=https://<tu_instancia>/api_jsonrpc.php
	ZABBIX_API_TOKEN=xxxxxxxxxxxxxxxxx  (o)
	ZABBIX_USER=usuario
	ZABBIX_PASSWORD=secreto

We prefer API token (Zabbix 5+) for simplicity.
"""

import os
import requests
import threading
from app import socketio, db
from app.models import ZabbixEvent
import time

JSON_RPC_VERSION = "2.0"


class ZabbixClient:
	def __init__(self, base_url=None, api_token=None, user=None, password=None, timeout=10):
		self.base_url = base_url or os.environ.get('ZABBIX_URL')
		if not self.base_url:
			raise ValueError("Falta ZABBIX_URL")
		self.api_token = api_token or os.environ.get('ZABBIX_API_TOKEN')
		self.user = user or os.environ.get('ZABBIX_USER')
		self.password = password or os.environ.get('ZABBIX_PASSWORD')
		self.timeout = timeout
		self._auth = None
		if not self.api_token and (self.user and self.password):
			self._login()
		else:
			self._auth = self.api_token  # token directo

	def _login(self):
		"""Realizar login tradicional para obtener auth token si no se usa API token."""
		payload = {
			"jsonrpc": JSON_RPC_VERSION,
			"method": "user.login",
			"params": {"user": self.user, "password": self.password},
			"id": 1
		}
		r = requests.post(self.base_url, json=payload, timeout=self.timeout)
		r.raise_for_status()
		data = r.json()
		if 'result' not in data:
			raise RuntimeError(f"Error login Zabbix: {data}")
		self._auth = data['result']

	def _call(self, method, params=None):
		params = params or {}
		headers = {'Content-Type': 'application/json'}
		payload = {
			"jsonrpc": JSON_RPC_VERSION,
			"method": method,
			"params": params,
			"id": int(time.time()),
		}
		if self._auth:
			payload['auth'] = self._auth
		r = requests.post(self.base_url, json=payload, headers=headers, timeout=self.timeout)
		r.raise_for_status()
		data = r.json()
		if 'error' in data:
			raise RuntimeError(f"Zabbix API error {data['error']}")
		return data.get('result')

	def get_active_triggers(self, min_severity=0, limit=50):
		"""Obtener triggers activos (PROBLEM) filtrando por severidad mínima."""
		result = self._call('trigger.get', {
			'output': ['triggerid', 'description', 'priority', 'lastchange'],
			'filter': {'value': 1},  # value=1 = PROBLEM
			'min_severity': min_severity,
			'sortfield': 'lastchange',
			'sortorder': 'DESC',
			'limit': limit
		})
		return result or []

	def get_events_for_trigger(self, triggerid, limit=20):
		result = self._call('event.get', {
			'output': ['eventid', 'clock', 'name', 'severity'],
			'object': 0,  # trigger
			'objectids': [triggerid],
			'sortfield': 'clock',
			'sortorder': 'DESC',
			'limit': limit
		})
		return result or []


def get_default_client():
	try:
		return ZabbixClient()
	except Exception as e:
		print(f"ZabbixClient no inicializado: {e}")
		return None


def start_zabbix_background():
	"""Start a background thread to periodically fetch Zabbix triggers and emit events.
	Safe to call at startup; it no-ops if Zabbix isn't configured.
	"""
	client = get_default_client()
	if not client:
		return

	seen_event_ids = set()

	def _loop():
		while True:
			try:
				triggers = client.get_active_triggers(min_severity=int(os.environ.get('ZABBIX_MIN_SEV', '0')))
				# For each trigger, optionally fetch the latest event for context
				for t in triggers:
					trig_id = t.get('triggerid')
					sev = int(t.get('priority', 0))
					lastchange = int(t.get('lastchange', 0))
					# Compose a synthetic event dict
					evt = {
						'severity': sev,
						'message': t.get('description') or 'Trigger',
						'time': lastchange,
						'triggerid': trig_id,
						'type': 'trigger'
					}
					# Emit to UI
					try:
						socketio.emit('zabbix_event', evt, namespace='/')
					except Exception:
						pass
					# Persist minimal record (best effort)
					try:
						with db.engine.begin() as conn:
							# Use ORM if metadata is bound; fall back to ORM session
							if trig_id and lastchange:
								key = f"{trig_id}:{lastchange}"
								if key in seen_event_ids:
									continue
								seen_event_ids.add(key)
								z = ZabbixEvent(
									eventid=key,
									triggerid=trig_id,
									host=None,
									severity=sev,
									status='PROBLEM',
									message=evt['message'],
									ts=lastchange
								)
								db.session.add(z)
								db.session.commit()
					except Exception:
						# Ignore DB errors silently to not disrupt the loop
						db.session.rollback()
						pass
			except Exception as e:
				print(f"Zabbix background error: {e}")
			# Interval configurable; default 30s
			time.sleep(int(os.environ.get('ZABBIX_POLL_INTERVAL', '30')))

	try:
		socketio.start_background_task(_loop)
	except Exception:
		threading.Thread(target=_loop, daemon=True).start()

