import os

class Config:
    SECRET_KEY = os.environ.get('UZyh__Bk9fRpa27H6DNf9eQrraLoexpwYs5ditpkHtDn_7eshPXtjL458cQ3p0-gInI')

    # Formato de conexión a PostgreSQL:
    # postgresql+psycopg2://usuario:contraseña@host:puerto/base_de_datos
    SQLALCHEMY_DATABASE_URI = os.environ.get(
        'DATABASE_URL',
        'postgresql+psycopg2://admin:12345@localhost:5432/zabbix_flights'
    )

    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Telegram bot configuration (set via environment)
    TELEGRAM_BOT_TOKEN = os.environ.get('TELEGRAM_BOT_TOKEN')
    TELEGRAM_CHAT_ID = os.environ.get('TELEGRAM_CHAT_ID')

    # Zabbix trigger names (comma-separated). These are matched case-insensitively
    # to detect specific automations. Configure via environment if needed.
    ZABBIX_TRIGGER_API_DOWN = [s.strip() for s in os.environ.get('ZABBIX_TRIGGER_API_DOWN', 'API no responde,API down,API caida').split(',') if s.strip()]
    ZABBIX_TRIGGER_TELEGRAM = [s.strip() for s in os.environ.get('ZABBIX_TRIGGER_TELEGRAM', 'exceso de vuelos,exceso vuelos,vuelos exceso').split(',') if s.strip()]

