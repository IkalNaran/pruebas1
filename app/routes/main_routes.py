from flask import Blueprint, render_template

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    return render_template('index.html')

@main_bp.route('/flights')
def flights():
    return render_template('flights.html')

@main_bp.route('/monitoring')
def monitoring():
    return render_template('monitoring.html')
