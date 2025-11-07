import os

class Config:
    SECRET_KEY = os.environ.get('UZyh__Bk9fRpa27H6DNf9eQrraLoexpwYs5ditpkHtDn_7eshPXtjL458cQ3p0-gInI')

    SQLALCHEMY_DATABASE_URI = os.environ.get(
        'DATABASE_URL',
        'postgresql+psycopg2://admin:12345@localhost:5432/zabbix_flights'
    )

    SQLALCHEMY_TRACK_MODIFICATIONS = False

    TELEGRAM_BOT_TOKEN = os.environ.get('TELEGRAM_BOT_TOKEN')
    TELEGRAM_CHAT_ID = os.environ.get('TELEGRAM_CHAT_ID')

    # ZABBIX TRIGGERS - DEFINICIÓN EXPLÍCITA
    ZABBIX_TRIGGER_API_DOWN = [
        "API no responde",
        "API is down", 
        "API caída",
        "HTTP API Failure",
        "Servicio API no disponible"
    ]
    
    ZABBIX_TRIGGER_TELEGRAM = [
        "exceso de vuelos",
        "Exceso de vuelos detectado", 
        "Too many flights",
        "Alerta volumen vuelos",
        "Flight count exceeded"
    ]