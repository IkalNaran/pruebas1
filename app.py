from flask import Flask, render_template, request, jsonify
import psycopg2
from psycopg2.extras import RealDictCursor
from config import config
import json
import os

def create_app():
    app = Flask(__name__)
    app.config.from_object(config['development'])
    
    def get_db_connection():
        """Establece conexión con PostgreSQL"""
        try:
            conn = psycopg2.connect(
                host=app.config['DB_HOST'],
                port=app.config['DB_PORT'],
                database=app.config['DB_NAME'],
                user=app.config['DB_USER'],
                password=app.config['DB_PASSWORD'],
                cursor_factory=RealDictCursor
            )
            return conn
        except Exception as e:
            print(f"Error conectando a PostgreSQL: {e}")
            return None

    @app.route('/')
    def index():
        """Página principal con Hola Mundo"""
        return render_template('index.html', 
                             mensaje="¡Hola Mundo desde Flask!",
                             framework="Flask",
                             database="PostgreSQL")

    @app.route('/api/health')
    def health_check():
        """Endpoint para verificar el estado de la aplicación y la BD"""
        conn = get_db_connection()
        db_status = "conectado" if conn else "desconectado"
        
        if conn:
            conn.close()
            
        return jsonify({
            "status": "ok",
            "message": "Aplicación Flask funcionando",
            "database": db_status,
            "framework": "Flask",
            "template_engine": "Jinja2"
        })

    @app.route('/api/init-db')
    def init_database():
        """Inicializa la base de datos con una tabla de ejemplo"""
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "No se pudo conectar a la base de datos"}), 500
        
        try:
            cur = conn.cursor()
            
            # Crear tabla de ejemplo
            cur.execute("""
                CREATE TABLE IF NOT EXISTS mensajes (
                    id SERIAL PRIMARY KEY,
                    mensaje TEXT NOT NULL,
                    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            
            # Insertar datos de ejemplo
            cur.execute("""
                INSERT INTO mensajes (mensaje) 
                VALUES ('¡Hola desde PostgreSQL!')
                ON CONFLICT DO NOTHING
            """)
            
            conn.commit()
            cur.close()
            conn.close()
            
            return jsonify({"message": "Base de datos inicializada correctamente"})
            
        except Exception as e:
            return jsonify({"error": str(e)}), 500

    @app.route('/api/mensajes')
    def get_mensajes():
        """Obtiene mensajes desde la base de datos"""
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "No se pudo conectar a la base de datos"}), 500
        
        try:
            cur = conn.cursor()
            cur.execute("SELECT * FROM mensajes ORDER BY creado_en DESC")
            mensajes = cur.fetchall()
            
            cur.close()
            conn.close()
            
            return jsonify({
                "mensajes": mensajes,
                "total": len(mensajes)
            })
            
        except Exception as e:
            return jsonify({"error": str(e)}), 500

    return app

if __name__ == '__main__':
    app = create_app()
    app.run(host='0.0.0.0', port=5000, debug=True)