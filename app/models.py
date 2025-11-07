from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from sqlalchemy.dialects.postgresql import JSON
from app import db


class FlightSnapshot(db.Model):
    __tablename__ = 'flight_snapshots'

    id = db.Column(db.Integer, primary_key=True)
    icao24 = db.Column(db.String(12), index=True)
    callsign = db.Column(db.String(32))
    lat = db.Column(db.Float)
    lon = db.Column(db.Float)
    altitude = db.Column(db.Float)
    speed = db.Column(db.Float)
    heading = db.Column(db.Float)
    last_seen = db.Column(db.Integer)
    raw = db.Column(JSON)                 # Guarda el JSON original del vuelo
    created_at = db.Column(
        db.DateTime, default=datetime.utcnow, index=True
    )

class SystemStatus(db.Model):
    __tablename__ = 'system_status'

    id = db.Column(db.Integer, primary_key=True)
    parameter = db.Column(db.String(50), unique=True)
    value = db.Column(db.String(100))
    updated_at = db.Column(
        db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )

class EventLog(db.Model):
    __tablename__ = 'event_logs'

    id = db.Column(db.Integer, primary_key=True)
    event_type = db.Column(db.String(50))
    description = db.Column(db.Text)
    created_at = db.Column(
        db.DateTime, default=datetime.utcnow
    )
