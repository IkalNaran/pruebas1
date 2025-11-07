from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_socketio import SocketIO
import os

db = SQLAlchemy()
socketio = SocketIO()

def create_app():
    app = Flask(__name__)
    app.config.from_object('app.config.Config')

    db.init_app(app)
    # Allow Socket.IO connections from the frontend (during development allow all origins).
    socketio.init_app(app, cors_allowed_origins='*')

    # start websocket background poller (only once when running server)
    # avoid double-start with the reloader by checking WERKZEUG_RUN_MAIN
    try:
        if not app.debug or os.environ.get('WERKZEUG_RUN_MAIN') == 'true':
            from app import websocket as _ws
            _ws.start_background_tasks(app)
            # Start Zabbix background fetcher if configured
            try:
                from app.zabbix_client import start_zabbix_background
                start_zabbix_background()
            except Exception:
                pass
    except Exception:
        # best-effort: if starting background tasks fails, continue
        pass

    # Registrar Blueprints
    from app.routes.main_routes import main_bp
    from app.routes.api_routes import api_bp
    app.register_blueprint(main_bp)
    app.register_blueprint(api_bp, url_prefix='/api')

    return app
