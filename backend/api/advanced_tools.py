from flask import Blueprint, jsonify, request
import random
import datetime

threat_bp = Blueprint('threats', __name__)
phish_sim_bp = Blueprint('phish_sim', __name__)

# --- Threat Dashboard ---
@threat_bp.route('/dashboard', methods=['GET'])
def get_dashboard_stats():
    # Mock Live Data
    global_attacks = [random.randint(50, 200) for _ in range(7)] # Last 7 days
    
    recent_breaches = [
        {"entity": "MegaCorp", "date": "2023-10-15", "records": "5M"},
        {"entity": "City Services", "date": "2023-11-02", "records": "120K"},
        {"entity": "ShopFast", "date": "2023-12-01", "records": "2M"},
    ]
    
    return jsonify({
        "global_attacks_last_7_days": global_attacks,
        "threat_level": "Elevated",
        "recent_breaches": recent_breaches,
        "active_malware_campaigns": ["Emotet", "Qakbot", "Cobalt Strike"]
    })

# --- Phishing Simulation ---
@phish_sim_bp.route('/create', methods=['POST'])
def create_campaign():
    data = request.get_json()
    target = data.get('target_email')
    
    if not target:
        return jsonify({"error": "Target email required"}), 400

    # Mock Campaign Creation
    campaign_id = f"CMP-{random.randint(1000, 9999)}"
    
    return jsonify({
        "campaign_id": campaign_id,
        "status": "Active",
        "target": target,
        "message": f"Simulated phishing email sent to {target}. Monitoring for clicks..."
    })
