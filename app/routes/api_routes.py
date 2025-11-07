from flask import Blueprint, jsonify, request
from app.opensky_client import get_all_states
from app.models import SystemStatus
from app.zabbix_client import update_system_status, log_event
from app import db    # ✅ ESTA ES LA BUENA
import time

api_bp = Blueprint('api', __name__, url_prefix='/api')

# Simple in-memory cache for the last successful OpenSky response
_last_snapshot = None
_last_snapshot_ts = 0.0
_CACHE_TTL = 120.0  # seconds


@api_bp.route('/ping')
def ping():
    return jsonify({'message': 'pong'})


@api_bp.route('/opensky', methods=['GET'])
def get_opensky_data():
    global _last_snapshot, _last_snapshot_ts

    lamin = request.args.get('lamin', type=float)
    lomin = request.args.get('lomin', type=float)
    lamax = request.args.get('lamax', type=float)
    lomax = request.args.get('lomax', type=float)

    data = get_all_states(lamin, lomin, lamax, lomax)

    # If the client function signals an error, try to serve cached snapshot when reasonable
    if isinstance(data, dict) and data.get('error'):
        status_code = data.get('status_code')
        now = time.time()
        if _last_snapshot and (now - _last_snapshot_ts) <= _CACHE_TTL:
            # Serve cached snapshot with a flag indicating it's cached
            cached = dict(_last_snapshot)
            cached['cached'] = True
            return jsonify(cached), 200
        # No cache available; return an error with the reported status code when provided
        return jsonify({
            'error': 'No se pudieron obtener datos de OpenSky',
            'detail': data.get('error'),
        }), int(status_code) if status_code else 502

    if not data:
        return jsonify({"error": "No se pudieron obtener datos"}), 502

    # Update cache and return
    _last_snapshot = data
    _last_snapshot_ts = time.time()
    return jsonify(data)

@api_bp.route('/zabbix/webhook', methods=['POST'])
def zabbix_webhook():
    data = request.json

    trigger = data.get('trigger')
    value = data.get('value')

    if not trigger:
        return jsonify({"error": "invalid format"}), 400
    
    update_system_status(trigger, value)

    log_event("ZABBIX_TRIGGER", f"{trigger} => {value}")

    return jsonify({"status": "ok"})

@api_bp.route("/system-status")
def system_status():
    from app.models import SystemStatus

    rows = SystemStatus.query.all()
    data = {r.parameter: r.value for r in rows}
    return jsonify(data)

@api_bp.route("/db-test")
def db_test():
    try:
        rows = SystemStatus.query.all()
        return jsonify({"status": "ok", "rows": len(rows)})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500