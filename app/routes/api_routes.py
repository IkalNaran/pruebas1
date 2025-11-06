from flask import Blueprint, jsonify, request
from app.opensky_client import get_all_states

api_bp = Blueprint('api', __name__)

@api_bp.route('/ping')
def ping():
    return jsonify({'message': 'pong'})

api_bp = Blueprint('api', __name__)

@api_bp.route('/opensky', methods=['GET'])
def get_opensky_data():
    lamin = request.args.get('lamin', type=float)
    lomin = request.args.get('lomin', type=float)
    lamax = request.args.get('lamax', type=float)
    lomax = request.args.get('lomax', type=float)

    data = get_all_states(lamin, lomin, lamax, lomax)
    if not data:
        return jsonify({"error": "No se pudieron obtener datos"}), 500

    return jsonify(data)
