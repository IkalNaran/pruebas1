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

