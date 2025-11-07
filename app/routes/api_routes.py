from flask import Blueprint, jsonify, request
from app.opensky_client import get_all_states
from app.models import SystemStatus
from app.zabbix_client import update_system_status, log_event, send_telegram_alert
from app import db, socketio    # usar Socket.IO para notificar al frontend
from flask import current_app
from scripts.cleanup import cleanup_if_needed
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
    cleanup_results = cleanup_if_needed()
    if cleanup_results.get("cleaned"):
        try:
            socketio.emit(
                "cleanup_status",
                {"status": "ACTIVE", "total": cleanup_results["total"]},
                namespace="/",
                broadcast=True
            )
        except Exception:
            pass    
    return jsonify(data)

@api_bp.route('/zabbix/webhook', methods=['POST'])
def zabbix_webhook():
    data = request.json
    trigger = data.get('trigger', '')

    # Zabbix webhook: se espera un JSON con al menos 'trigger' y 'value'.
    trigger = data.get('trigger') or data.get('trigger_name') or ''
    value = data.get('value') or data.get('status') or ''
    severity = data.get('severity') or data.get('priority') or ''

    if not trigger:
        return jsonify({"error": "invalid format"}), 400

    # Guardar en DB (parámetro / valor) y loguear evento
    update_system_status(trigger, value)
    log_event("ZABBIX_TRIGGER", f"{trigger} => {value}")

    # Normalizar para detección de triggers específicos
    t = (trigger or '').strip()
    t_lower = t.lower()
    v = (value or '').lower()
    s = (severity or '').lower()

    # Emitir notificación genérica al frontend
    try:
        socketio.emit('zabbix_event', {'message': f"{trigger} => {value}", 'severity': severity or None}, namespace='/', broadcast=True)
    except Exception:
        pass

    # Trigger: API no responde -> marcar API como 'down' y emitir status_update (indicador rojo)
    try:
        # Prefer exact configurable trigger-name matching (case-insensitive)
        api_down_names = [n.lower() for n in current_app.config.get('ZABBIX_TRIGGER_API_DOWN', [])]
        matched_api_down = (t_lower in api_down_names) or (s and s in ('disaster', 'high', 'critical'))

        # Fallback heuristic if no exact match
        if not matched_api_down:
            matched_api_down = ('api' in t_lower and ('no responde' in t_lower or 'caída' in t_lower or 'caida' in t_lower or 'down' in v or 'down' in t_lower))

        if matched_api_down:
            # Actualizar estado legible en la tabla de SystemStatus
            update_system_status('api', 'down')
            try:
                socketio.emit('status_update', {'api': 'down'}, namespace='/', broadcast=True)
            except Exception:
                pass

    except Exception:
        # no bloquear el webhook si algo falla en el manejo de alerta
        pass

    # Trigger: exceso de vuelos -> reflejar alerta tipo Telegram en la app
    try:
        # Exact configurable trigger matching for Telegram-alert triggers
        telegram_names = [n.lower() for n in current_app.config.get('ZABBIX_TRIGGER_TELEGRAM', [])]
        matched_telegram = (t_lower in telegram_names)

        # Fallback heuristic if no exact match
        if not matched_telegram:
            matched_telegram = (('exceso' in t_lower and 'vuelos' in t_lower) or ('exceso de vuelos' in t_lower) or ('vuelos' in t_lower and 'exceso' in t_lower))

        if matched_telegram:
            # Marcador simple para la UI (puede usarse para mostrar ícono)
            update_system_status('zabbix_telegram_alert', '1')
            try:
                socketio.emit('zabbix_event', {'message': f"{trigger} => {value}", 'severity': 'info', 'icon': 'telegram'}, namespace='/', broadcast=True)
                # Enviar notificación a Telegram si está configurado
                try:
                    send_telegram_alert(f"Alerta: {trigger}", f"Valor: {value}")
                except Exception:
                    pass
            except Exception:
                pass
    except Exception:
        pass

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


@api_bp.route('/debug/emit_fpm/<int:count>', methods=['GET'])
def debug_emit_fpm(count):
    """
    Dev-only debug route to emit a `flights_per_min` Socket.IO event.
    Only active when Flask app is running in DEBUG mode (to avoid accidental exposure).

    Usage (dev): GET /debug/emit_fpm/5
    Emits: socketio.emit('flights_per_min', {'value': count})
    """
    # Only allow in debug mode to reduce accidental exposure in production
    if not current_app.config.get('DEBUG', False):
        return jsonify({'error': 'debug route disabled'}), 403

    try:
        # Broadcast the synthetic metric so clients update chart & homepage indicator
        socketio.emit('flights_per_min', {'value': int(count)}, namespace='/', broadcast=True)
        return jsonify({'status': 'ok', 'emitted': int(count)})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500