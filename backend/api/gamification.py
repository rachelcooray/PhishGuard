from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db
from models.user import User
from models.quiz import Quiz

gamification_bp = Blueprint('gamification', __name__)

@gamification_bp.route('/stats', methods=['GET'])
@jwt_required()
def get_user_stats():
    user_id = get_jwt_identity()
    user = db.session.get(User, int(user_id))
    if not user: return jsonify({"error": "User not found"}), 404
    
    # Calculate next level threshold: Level * 100 XP
    next_level_xp = user.level * 100
    
    return jsonify({
        "xp": user.xp,
        "level": user.level,
        "next_level_xp": next_level_xp,
        "completed_modules": user.completed_modules or []
    })

@gamification_bp.route('/quiz/<int:module_id>', methods=['GET'])
def get_quiz(module_id):
    quizzes = Quiz.query.filter_by(module_id=module_id).all()
    if not quizzes: return jsonify([]), 200
    return jsonify([q.to_dict() for q in quizzes])

@gamification_bp.route('/quiz/submit', methods=['POST'])
@jwt_required()
def submit_quiz():
    user_id = get_jwt_identity()
    data = request.get_json()
    module_id = data.get('module_id')
    score = data.get('score', 0) # Number of correct answers
    
    user = db.session.get(User, int(user_id))
    
    # Award XP: 10 XP per correct answer
    earned_xp = score * 10
    user.xp += earned_xp
    
    # Check Level Up
    if user.xp >= user.level * 100:
        user.xp -= user.level * 100
        user.level += 1
        level_up = True
    else:
        level_up = False
        
    # Mark module as complete if it's new
    completed = user.completed_modules or []
    if module_id not in completed and score > 0: # Weak check, ideally pass threshold
        completed.append(module_id)
        user.completed_modules = completed
        user.xp += 50 # Bonus for module completion
        earned_xp += 50

    db.session.commit()
    
    return jsonify({
        "earned_xp": earned_xp,
        "new_total_xp": user.xp,
        "new_level": user.level,
        "level_up": level_up
    })

@gamification_bp.route('/seed_quizzes', methods=['POST'])
def seed_quizzes():
    if Quiz.query.first(): return jsonify({"message": "Already seeded"}), 200
    
    # Module 1: Phishing
    q1 = Quiz(module_id=1, question="What is the most common indicator of a phishing email?", options=["Urgent language", "Proper grammar", "Personalized greeting", "Sent from known contact"], correct_index=0)
    q2 = Quiz(module_id=1, question="What should you do if you suspect a link?", options=["Click it immediately", "Hover over it to see the URL", "Reply to the sender", "Forward to friends"], correct_index=1)
    
    # Module 2: Passwords
    q3 = Quiz(module_id=2, question="Which password is strongest?", options=["Password123", "Rachel2024", "Tr0ub4dour&3", "12345678"], correct_index=2)
    
    # Module 3: Social Engineering
    q4 = Quiz(module_id=3, question="What is 'Pretexting'?", options=["Sending malware", "Creating a fabricated scenario to steal info", "Hacking wifi", "Guessing passwords"], correct_index=1)

    db.session.add_all([q1, q2, q3, q4])
    db.session.commit()
    return jsonify({"message": "Quizzes seeded"})
