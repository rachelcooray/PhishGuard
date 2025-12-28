from flask import Blueprint, request, jsonify
import tldextract
import re
import socket
import joblib
import os
import numpy as np

url_bp = Blueprint('url', __name__)

# Load Model
model_path = os.path.join(os.path.dirname(__file__), '../ml/phishing_model.pkl')
print(f"DEBUG: Attempting to load model from: {os.path.abspath(model_path)}")
try:
    ml_model = joblib.load(model_path)
    print("ML Model loaded successfully")
except Exception as e:
    print(f"ML Model not found/error: {e}")
    ml_model = None

def extract_features(url):
    features = []
    features.append(len(url)) # length
    features.append(url.count('.')) # dot_count
    features.append(1 if 'https' in url else 0) # has_https
    features.append(1 if re.search(r'(\d{1,3}\.){3}\d{1,3}', url) else 0) # has_ip
    features.append(1 if '@' in url else 0) # at_symbol
    features.append(sum(c.isdigit() for c in url)) # digit_count
    return np.array([features])

def is_suspicious(url):
    flags = []
    
    # 1. Check for IP address in URL
    ip_pattern = r'(\d{1,3}\.){3}\d{1,3}'
    if re.search(ip_pattern, url):
        flags.append("URL contains IP address instead of domain")
        
    # 2. Extract domain parts
    try:
        extracted = tldextract.extract(url)
        domain = extracted.domain
        suffix = extracted.suffix
        subdomain = extracted.subdomain
        
        # 3. Long subdomains (common in phishing)
        if len(subdomain) > 20: 
            flags.append("Extremely long subdomain detected")
            
        # 5. Suspicious keywords
        keywords = ['login', 'verify', 'update', 'secure', 'account', 'banking']
        if any(k in subdomain or k in domain for k in keywords):
            # Only flag if not on the main domain (simple heuristic)
            # Real logic would need a whitelist of legit domains
            pass 
            
    except:
        pass # Handle invalid URLs gracefully

    # 4. Too many dots in domain
    if url.count('.') > 4:
        flags.append("Excessive dots in URL")
        
    # 6. HTTP vs HTTPS
    if not url.startswith("https://"):
        flags.append("Not using HTTPS")

    # Rule-based Score
    rule_score = len(flags) * 20 

    # ML Prediction
    ml_prob = 0
    if ml_model:
        try:
            feats = extract_features(url)
            ml_prob = ml_model.predict_proba(feats)[0][1] * 100 # Probability of class 1 (Phishing)
        except Exception as e:
            print(f"ML Prediction failed: {e}")

    # Final Combined Score
    final_score = max(rule_score, ml_prob)
    
    status = "Safe"
    if final_score > 30: status = "Suspicious"
    if final_score >= 70: status = "Dangerous"
    
    return {
        "status": status,
        "risk_score": int(final_score),
        "flags": flags,
        "ml_probability": f"{ml_prob:.1f}%"
    }

@url_bp.route('/scan', methods=['POST'])
def scan_url():
    data = request.json
    url = data.get('url', '')
    
    if not url:
        return jsonify({"error": "No URL provided"}), 400
        
    result = is_suspicious(url)
    
    return jsonify(result)
