import json
from unittest.mock import patch, Mock
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime
from flask import json, Flask
from app.routes.api_routes import zabbix_webhook


def test_webhook_api_down_emits_status_update():
    app = Flask(__name__)
    payload = {"trigger": "API no responde", "value": "down", "severity": "high"}

    # Patch update_system_status and log_event to avoid DB writes
    with patch('app.routes.api_routes.update_system_status') as mock_update, \
         patch('app.routes.api_routes.log_event') as mock_log, \
         patch('app.routes.api_routes.socketio') as mock_socket:

        mock_socket.emit = Mock()

        with app.test_request_context('/api/zabbix/webhook', method='POST', json=payload):
            resp = zabbix_webhook()
            # resp is a Response object
            assert resp.status_code == 200
            data = resp.get_json()
            assert data.get('status') == 'ok'

        # update_system_status called for trigger and for api state
        assert mock_update.called
        # socketio.emit must be called at least once for zabbix_event or status_update
        assert mock_socket.emit.call_count >= 1


def test_webhook_exceso_vuelos_calls_telegram():
    app = Flask(__name__)
    payload = {"trigger": "exceso de vuelos", "value": "120", "severity": "info"}

    with patch('app.routes.api_routes.update_system_status') as mock_update, \
         patch('app.routes.api_routes.log_event') as mock_log, \
         patch('app.routes.api_routes.socketio') as mock_socket, \
         patch('app.routes.api_routes.send_telegram_alert') as mock_send_telegram:

        mock_socket.emit = Mock()
        mock_send_telegram.return_value = True

        with app.test_request_context('/api/zabbix/webhook', method='POST', json=payload):
            resp = zabbix_webhook()
            assert resp.status_code == 200
            data = resp.get_json()
            assert data.get('status') == 'ok'

        # ensure we attempted to set a zabbix_telegram_alert
        mock_update.assert_any_call('zabbix_telegram_alert', '1')
        # ensure telegram send was called
        assert mock_send_telegram.called


def cleanup_if_needed():
    conn = psycopg2.connect(
        dbname="TU_DB",
        user="TU_USER",
        password="TU_PASS",
        host="localhost"
    )
    cur = conn.cursor(cursor_factory=RealDictCursor)

    # 1. Obtener el número de vuelos actuales
    cur.execute("SELECT COUNT(*) AS total FROM flight_snapshots;")
    total = cur.fetchone()["total"]

    # Si no supera 100, no se hace nada
    if total <= 100:
        print(f"Vuelos actuales: {total} — sin limpieza.")
        conn.close()
        return

    print("⚠ LIMPIEZA ACTIVA — demasiados vuelos en la BD")

    # 2. Actualizar estado del sistema
    cur.execute("""
        UPDATE system_status
        SET value = 'ACTIVE', updated_at = NOW()
        WHERE parameter = 'db_cleanup';
    """)

    # Log del inicio
    cur.execute("""
        INSERT INTO event_logs(event_type, description)
        VALUES ('CLEANUP_START', 'Se inició limpieza por exceso de vuelos');
    """)

    # 3. Borrar los registros viejos
    cur.execute("""
        DELETE FROM flight_snapshots
        WHERE id NOT IN (
            SELECT id
            FROM flight_snapshots
            ORDER BY created_at DESC
            LIMIT 100
        );
    """)

    # Log del final de limpieza
    cur.execute("""
        INSERT INTO event_logs(event_type, description)
        VALUES ('CLEANUP_END', 'Limpieza completada, solo se mantienen los últimos 100 vuelos');
    """)

    # 4. Volver el estado del sistema a IDLE
    cur.execute("""
        UPDATE system_status
        SET value = 'IDLE', updated_at = NOW()
        WHERE parameter = 'db_cleanup';
    """)

    conn.commit()
    conn.close()

    print("Limpieza completada. Sistema normal.")