from flask import Blueprint, request, jsonify
from zxcvbn import zxcvbn

password_bp = Blueprint('password', __name__)

@password_bp.route('/check-strength', methods=['POST'])
def check_strength():
    data = request.json
    password = data.get('password', '')

    if not password:
        return jsonify({"error": "No password provided"}), 400

    results = zxcvbn(password)
    
    # Extract useful data
    score = results['score'] # 0-4
    feedback = results['feedback']
    crack_time = results['crack_times_display']['offline_slow_hashing_1e4_per_second']
    
    return jsonify({
        "score": score,
        "suggestions": feedback['suggestions'],
        "warning": feedback['warning'],
        "crack_time_display": crack_time
    })
