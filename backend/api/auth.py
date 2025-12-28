from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
import bcrypt
from models import db
from models.user import User
from sqlalchemy.exc import IntegrityError

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.json
    email = data.get('email')
    password = data.get('password')
    name = data.get('name')

    if not email or not password:
        return jsonify({"error": "Email and password required"}), 400

    hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    new_user = User(email=email, password_hash=hashed, name=name)

    try:
        db.session.add(new_user)
        db.session.commit()
        
        access_token = create_access_token(identity=str(new_user.id))
        return jsonify({
            "message": "User registered successfully",
            "token": access_token,
            "user": new_user.to_dict()
        }), 201
    except IntegrityError:
        db.session.rollback()
        return jsonify({"error": "Email already exists"}), 409

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    user = User.query.filter_by(email=email).first()

    if user and bcrypt.checkpw(password.encode('utf-8'), user.password_hash.encode('utf-8')):
        access_token = create_access_token(identity=str(user.id))
        return jsonify({
            "message": "Login successful",
            "token": access_token,
            "user": user.to_dict()
        }), 200
    
    return jsonify({"error": "Invalid email or password"}), 401

@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def profile():
    user_id = get_jwt_identity()
    user = db.session.get(User, int(user_id))
    if not user:
        return jsonify({"error": "User not found"}), 404
    return jsonify(user.to_dict()), 200
