from flask import Blueprint, jsonify
from flask_cors import cross_origin
from models import db
from models.module import Module

learning_bp = Blueprint('learning', __name__)

@learning_bp.route('/modules', methods=['GET'])
def get_modules():
    modules = Module.query.all()
    return jsonify([m.to_dict() for m in modules])

@learning_bp.route('/modules/<int:module_id>', methods=['GET'])
def get_module_detail(module_id):
    module = db.session.get(Module, module_id)
    if not module:
        return jsonify({"error": "Module not found"}), 404
    return jsonify(module.to_dict_full())

@learning_bp.route('/seed', methods=['POST'])
def seed_data():
    # Only seed if empty
    if Module.query.first():
         return jsonify({"message": "Data already seeded"}), 200

    m1 = Module(
        title="Phishing 101",
        description="Learn the basics of phishing attacks and how to spot them.",
        estimated_time=5,
        content="""
# Phishing 101

Phishing is a type of social engineering where an attacker sends a fraudulent message designed to trick a human victim into revealing sensitive information to the attacker or to deploy malicious software on the victim's infrastructure like ransomware.

## Common Signs
1. **Urgency**: "Act now or your account will be deleted!"
2. **Suspicious Sender**: `support@google-security-update.com` (Fake domain)
3. **Generic Greetings**: "Dear Customer" instead of your name.
4. **Mismatched Links**: The link text says `paypal.com` but hovers to `paypaI-secure.com`.

## How to Protect Yourself
- Verify the sender's email address.
- Hover over links before clicking.
- Enable 2FA on all accounts.
""".strip()
    )

    m2 = Module(
        title="Safe Browsing Habits",
        description="Best practices for browsing the internet securely.",
        estimated_time=8,
        content="""
# Safe Browsing Habits

## 1. Look for the Lock
Always ensure the website uses HTTPS. Look for the padlock icon in the address bar.

## 2. Keep Software Updated
Browser updates often contain critical security patches.

## 3. Be Careful with Downloads
Only download files from trusted sources. If a site asks you to download a "codec" or "player" to watch a video, it's likely malware.

## 4. Use a Password Manager
Don't reuse passwords. Use a manager to generate unique, strong passwords for every site.
""".strip()
    )
    
    m3 = Module(
        title="Social Engineering",
        description="How attackers manipulate you into giving up secrets.",
        estimated_time=10,
        content="""
# Social Engineering

Social engineering is the art of manipulating people so they give up confidential information. The types of information these criminals are seeking can vary, but when individuals are targeted the criminals are usually trying to trick you into giving them your passwords or bank information.

## Types
- **Phishing**: Email based scams.
- **Vishing**: Phone voice scams.
- **Smishing**: SMS text scams.
- **Pretexting**: Creating a fabricated scenario (pretext) to engage a victim.

## Defense
- Slow down. Spammers want you to act first and think later.
- Verify the identity. If a "bank" calls you, hang up and call the number on the back of your card.
""".strip()
    )

    db.session.add_all([m1, m2, m3])
    db.session.commit()
    
    return jsonify({"message": "Seeded learning modules"}), 201
