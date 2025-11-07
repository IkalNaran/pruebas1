from app.models import db, SystemStatus, EventLog
from datetime import datetime
from flask import current_app
import requests

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


def send_telegram_message(text):
    """Send a Telegram message using bot token and chat id from app config.

    Returns True on success, False otherwise.
    """
    try:
        token = current_app.config.get('TELEGRAM_BOT_TOKEN')
        chat_id = current_app.config.get('TELEGRAM_CHAT_ID')
    except RuntimeError:
        # No app context
        return False

    if not token or not chat_id:
        return False

    url = f'https://api.telegram.org/bot{token}/sendMessage'
    payload = {'chat_id': chat_id, 'text': text}
    try:
        resp = requests.post(url, json=payload, timeout=5)
        return resp.ok
    except Exception:
        return False


def send_telegram_alert(title, body):
    """Convenience wrapper to format and send an alert to Telegram and log the outcome."""
    text = f"{title}\n\n{body}"
    ok = send_telegram_message(text)
    log_event('TELEGRAM', f"sent={ok} title={title}")
    return ok
