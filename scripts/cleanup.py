from app import create_app
from app.models import db, FlightSnapshot, SystemStatus
from datetime import datetime, timedelta

app = create_app()

with app.app_context():

    # marcar estado activo
    status = SystemStatus.query.filter_by(parameter="db_cleanup").first()
    status.value = "RUNNING"
    status.updated_at = datetime.utcnow()
    db.session.commit()

    # borrar vuelos viejos
    cutoff = datetime.utcnow() - timedelta(minutes=10)
    FlightSnapshot.query.filter(FlightSnapshot.created_at < cutoff).delete()
    db.session.commit()

    # marcar como terminado
    status.value = "IDLE"
    status.updated_at = datetime.utcnow()
    db.session.commit()

    print("✅ Limpieza ejecutada")
