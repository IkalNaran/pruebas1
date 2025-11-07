import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_socketio import SocketIO

# Importamos la configuración
from app.config import Config

# Inicializamos objetos globales
db = SQLAlchemy()
socketio = SocketIO(cors_allowed_origins="*")


def create_app():
    """Crea e inicializa la aplicación Flask."""
    app = Flask(__name__)

    # Cargar configuración
    app.config.from_object(Config)

    # Inicializar base de datos
    db.init_app(app)

    # Inicializar SocketIO
    socketio.init_app(app)

    # Registrar blueprints
    from app.routes.main_routes import main_bp
    from app.routes.api_routes import api_bp

    app.register_blueprint(main_bp)
    app.register_blueprint(api_bp, url_prefix="/api")

    # Iniciar tareas en background (solo si no estamos ejecutando tests)
    from app.websocket import start_background_tasks
    with app.app_context():
        start_background_tasks(app)

    return app


# Punto de entrada opcional para ejecutar la app manualmente
if __name__ == "__main__":
    app = create_app()
    socketio.run(app, host="0.0.0.0", port=5000, debug=True)
