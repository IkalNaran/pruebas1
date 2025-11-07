from app import db


class ZabbixEvent(db.Model):
	__tablename__ = 'zabbix_events'

	id = db.Column(db.Integer, primary_key=True)
	eventid = db.Column(db.String(64), unique=True, index=True)
	triggerid = db.Column(db.String(64), index=True)
	host = db.Column(db.String(255), index=True)
	severity = db.Column(db.Integer)
	status = db.Column(db.String(32))  # e.g., 'PROBLEM' or 'OK'
	message = db.Column(db.String(1024))
	ts = db.Column(db.Integer, index=True)  # epoch seconds

	def __repr__(self):
		return f"<ZabbixEvent eventid={self.eventid} host={self.host} sev={self.severity} status={self.status}>"

