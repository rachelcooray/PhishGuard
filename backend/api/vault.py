from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from cryptography.fernet import Fernet
from models import db
from models.vault import VaultEntry
import os

vault_bp = Blueprint('vault', __name__)

# Encryption Key (Should be env var, but static for demo)
# In real app, key should be derived from User Master Password
ENCRYPTION_KEY = Fernet.generate_key() 
cipher_suite = Fernet(ENCRYPTION_KEY)

@vault_bp.route('/add', methods=['POST'])
@jwt_required()
def add_entry():
    user_id = get_jwt_identity()
    data = request.get_json()
    
    service = data.get('service')
    username = data.get('username')
    password = data.get('password')
    
    if not all([service, username, password]):
        return jsonify({"error": "Missing fields"}), 400
        
    # Encrypt password
    encrypted_pw = cipher_suite.encrypt(password.encode('utf-8')).decode('utf-8')
    
    entry = VaultEntry(
        user_id=user_id,
        service_name=service,
        username=username,
        encrypted_password=encrypted_pw
    )
    
    db.session.add(entry)
    db.session.commit()
    
    return jsonify({"message": "Saved securely"}), 201

@vault_bp.route('/list', methods=['GET'])
@jwt_required()
def list_entries():
    user_id = get_jwt_identity()
    entries = VaultEntry.query.filter_by(user_id=user_id).all()
    return jsonify([e.to_dict() for e in entries])

@vault_bp.route('/reveal/<int:entry_id>', methods=['POST'])
@jwt_required()
def reveal_password(entry_id):
    user_id = get_jwt_identity()
    entry = db.session.get(VaultEntry, entry_id)
    
    if not entry or str(entry.user_id) != str(user_id):
        return jsonify({"error": "Not found"}), 404
        
    try:
        decrypted_pw = cipher_suite.decrypt(entry.encrypted_password.encode('utf-8')).decode('utf-8')
        return jsonify({"password": decrypted_pw})
    except Exception:
        return jsonify({"error": "Decryption failed"}), 500
