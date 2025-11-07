import os
import time
from app.opensky_client import get_all_states as _opensky_get

# Simple in-memory provider status to expose connection health to UI and API
_STATUS = {
    'last_attempt': None,
    'last_success': None,
    'provider': None,           # 'opensky' | 'adsb.lol' | None
    'cached': False,            # True when serving cached/bootstrap
    'bootstrap': False,
    'api': 'unknown',           # 'ok' | 'warn' | 'down' | 'unknown'
    'error': None,              # last error message
}


def _set_status(attempted=True, success=False, provider=None, cached=False, bootstrap=False, error=None):
    now = int(time.time())
    if attempted:
        _STATUS['last_attempt'] = now
    if success:
        _STATUS['last_success'] = now
    if provider is not None:
        _STATUS['provider'] = provider
    _STATUS['cached'] = bool(cached)
    _STATUS['bootstrap'] = bool(bootstrap)
    _STATUS['error'] = error
    # derive api level
    if error and not success:
        _STATUS['api'] = 'down'
    else:
        # if we returned data but it was cached/bootstrap, warn
        _STATUS['api'] = 'warn' if (cached or bootstrap) else 'ok'


def get_status():
    """Return a shallow copy of current provider status."""
    return dict(_STATUS)


def _is_error_payload(data):
    return (data is None) or (isinstance(data, dict) and data.get('error'))


def get_states_any(lamin=None, lomin=None, lamax=None, lomax=None):
    """Fetch from OpenSky only (no ADSB.lol fallback). Returns OpenSky-like dict and updates status."""
    _set_status(attempted=True)
    data = _opensky_get(lamin, lomin, lamax, lomax)
    if not _is_error_payload(data):
        if isinstance(data, dict):
            data['provider'] = 'opensky'
        cached = bool(isinstance(data, dict) and data.get('cached'))
        bootstrap = bool(isinstance(data, dict) and data.get('bootstrap'))
        _set_status(success=True, provider='opensky', cached=cached, bootstrap=bootstrap)
        return data
    # Error path: keep status as down and propagate error
    err = data.get('error') if isinstance(data, dict) else 'unknown error'
    _set_status(success=False, provider='opensky', cached=False, bootstrap=False, error=err)
    return data
