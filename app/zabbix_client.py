from app.models import db, SystemStatus, EventLog
from datetime import datetime

def update_system_status(parameter, value):
    row = SystemStatus.query.filter_by(parameter=parameter).first()
    if row:
        row.value = value
        row.updated_at = datetime.utcnow()
    else:
        row = SystemStatus(parameter=parameter, value=value)
        db.session.add(row)
    db.session.commit()

def log_event(event_type, description):
    log = EventLog(event_type=event_type, description=description)
    db.session.add(log)
    db.session.commit()
