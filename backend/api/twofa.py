from flask import Blueprint, request, jsonify
import pyotp
import qrcode
import io
import base64

twofa_bp = Blueprint('twofa', __name__)

# Temporary in-memory store for demo (User ID -> Secret)
# In prod, store this in DB User model
user_secrets = {} 

@twofa_bp.route('/generate', methods=['POST'])
def generate_secret():
    data = request.get_json()
    user_id = data.get('user_id', 'demo_user')
    
    # Generate random base32 secret
    secret = pyotp.random_base32()
    user_secrets[user_id] = secret
    
    # Generate URI for QR Code
    uri = pyotp.totp.TOTP(secret).provisioning_uri(name=user_id, issuer_name="PhishGuard Demo")
    
    # Generate QR Code Image
    img = qrcode.make(uri)
    buffered = io.BytesIO()
    img.save(buffered, format="PNG")
    qr_base64 = base64.b64encode(buffered.getvalue()).decode('utf-8')
    
    return jsonify({
        "secret": secret,
        "qr_code": f"data:image/png;base64,{qr_base64}",
        "uri": uri
    })

@twofa_bp.route('/verify', methods=['POST'])
def verify_code():
    data = request.get_json()
    user_id = data.get('user_id', 'demo_user')
    code = data.get('code', '')
    
    secret = user_secrets.get(user_id)
    
    if not secret:
        return jsonify({"valid": False, "message": "No secret found. Generate one first."}), 400
        
    totp = pyotp.TOTP(secret)
    is_valid = totp.verify(code)
    
    return jsonify({
        "valid": is_valid,
        "message": "Code is valid!" if is_valid else "Invalid or expired code."
    })
