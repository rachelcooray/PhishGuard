from flask import Blueprint, request, jsonify
import re

email_analysis_bp = Blueprint('email_analysis', __name__)

SUSPICIOUS_KEYWORDS = [
    "urgent", "verify your account", "suspended", "bank", "password expiration",
    "lottery", "winner", "inheritance", "transfer", "western union", "irs", "tax refund"
]

@email_analysis_bp.route('/analyze', methods=['POST'])
def analyze_email():
    data = request.get_json()
    text = data.get('text', '').lower()
    sender = data.get('sender', '').lower()

    if not text:
        return jsonify({"error": "Email content is required"}), 400

    flags = []
    score = 0
    
    # 1. Keyword Analysis
    found_keywords = [word for word in SUSPICIOUS_KEYWORDS if word in text]
    if found_keywords:
        score += len(found_keywords) * 10
        flags.append(f"Suspicious keywords found: {', '.join(found_keywords)}")

    # 2. Urgency Detection
    if "urgent" in text or "immediately" in text or "24 hours" in text:
        score += 20
        flags.append("Sense of urgency detected (common phishing tactic).")

    # 3. Link Detection (Simulated)
    if "http" in text:
        score += 10
        flags.append("Contains links. Be cautious.")

    # 4. Sender Check
    if sender and not re.match(r"[^@]+@[^@]+\.[^@]+", sender):
        score += 30
        flags.append("Invalid sender email format.")
    elif sender and ("gmail.com" in sender or "yahoo.com" in sender) and ("bank" in text or "support" in text):
        score += 20
        flags.append("Official-sounding email sent from public domain (Gmail/Yahoo).")

    # Determine Verdict
    risk_level = "Safe"
    if score > 50:
        risk_level = "High Risk"
    elif score > 20:
        risk_level = "Suspicious"

    return jsonify({
        "risk_level": risk_level,
        "score": min(score, 100),
        "flags": flags
    })
