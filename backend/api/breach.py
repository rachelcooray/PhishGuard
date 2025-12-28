from flask import Blueprint, request, jsonify
import hashlib
import requests

breach_bp = Blueprint('breach', __name__)

@breach_bp.route('/check', methods=['POST'])
def check_breach():
    data = request.get_json()
    password = data.get('password', '')

    if not password:
        return jsonify({"error": "Password is required"}), 400

    # 1. Hash the password using SHA-1 (Required by HIBP API)
    sha1_password = hashlib.sha1(password.encode('utf-8')).hexdigest().upper()
    
    # 2. Split into prefix (5 chars) and suffix
    prefix = sha1_password[:5]
    suffix = sha1_password[5:]

    # 3. Query HIBP API with just the prefix (K-Anonymity)
    url = f"https://api.pwnedpasswords.com/range/{prefix}"
    
    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        
        # 4. Check if our suffix exists in the response
        hashes = (line.split(':') for line in response.text.splitlines())
        count = 0
        for h, c in hashes:
            if h == suffix:
                count = int(c)
                break
        
        return jsonify({
            "breached": count > 0,
            "count": count,
            "message": f"This password has been seen in {count} data breaches." if count > 0 else "This password has not been found in known breaches."
        })

    except requests.RequestException as e:
        return jsonify({"error": "Failed to connect to breach database", "details": str(e)}), 503
