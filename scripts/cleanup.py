from app.models import db, FlightSnapshot, SystemStatus, EventLog
from sqlalchemy import text
from datetime import datetime, timedelta

MAX_FLIGHTS = 100

def cleanup_if_needed():
    # 1. Contar vuelos actuales
    count = FlightSnapshot.query.count()

    # Si no hemos excedido el límite, también hacemos limpieza por tiempo
    if count <= MAX_FLIGHTS:
        return {"action": "none"}

    # 2. Marcar limpieza activa
    status = SystemStatus.query.filter_by(parameter="db_cleanup").first()
    status.value = "RUNNING"
    status.updated_at = datetime.utcnow()
    db.session.commit()

    # 3. Obtener los IDs más recientes que queremos conservar
    ids_keep = db.session.execute(
        text("""
            SELECT id
            FROM flight_snapshots
            ORDER BY created_at DESC
            LIMIT :max
        """),
        {"max": MAX_FLIGHTS}
    ).fetchall()

    ids_keep = [row[0] for row in ids_keep]

    # 4. Eliminar todo lo que NO esté en los recientes
    db.session.execute(
        text("""
            DELETE FROM flight_snapshots
            WHERE id NOT IN :ids
        """),
        {"ids": tuple(ids_keep)}
    )

    db.session.commit()

    # 5. Volver a estado normal
    status.value = "IDLE"
    status.updated_at = datetime.utcnow()
    db.session.commit()

    return {
        "action": "cleanup",
        "kept": len(ids_keep),
        "removed": count - len(ids_keep)
    }