from flask import Blueprint, request, jsonify
import requests
import re

vuln_bp = Blueprint('vuln', __name__)

@vuln_bp.route('/test', methods=['POST'])
def test_vulnerability():
    data = request.get_json()
    target_url = data.get('url', '')

    if not target_url:
        return jsonify({"error": "URL is required"}), 400

    if not target_url.startswith(('http://', 'https://')):
        target_url = 'http://' + target_url

    findings = []
    
    # Simulation logic (Safe)
    # 1. Check for 'http' (Encryption)
    if target_url.startswith('http://'):
        findings.append({
            "type": "Unencrypted Transport",
            "severity": "Medium",
            "description": "Site is using HTTP instead of HTTPS. Data is sent in plain text."
        })
    
    # 2. Check for suspicious parameters (Reflected XSS simulation)
    # We don't actually attack, just check if URL has query params that might be vulnerable
    if '?' in target_url:
        findings.append({
            "type": "Parameter Exposure",
            "severity": "Low",
            "description": "URL parameters detected. Ensure input sanitization to prevent XSS/SQLi."
        })

    # 3. Simulated Header Check (Mocking a real response check)
    try:
        # In a real tool we would requests.get(target_url) and check headers
        # But to avoid triggering firewalls/abuse, we'll keep it light or mock it.
        # Let's do a safe HEAD request.
        response = requests.head(target_url, timeout=3)
        headers = response.headers
        
        if 'X-Frame-Options' not in headers:
             findings.append({
                "type": "Missing Clickjacking Protection",
                "severity": "Low",
                "description": "X-Frame-Options header missing."
            })
        
        if 'Content-Security-Policy' not in headers:
            findings.append({
                "type": "Missing CSP",
                "severity": "Low",
                "description": "Content-Security-Policy header missing."
            })
            
    except Exception as e:
        findings.append({
            "type": "Connection Error",
            "severity": "Info",
            "description": f"Could not connect to target: {str(e)}"
        })

    return jsonify({
        "url": target_url,
        "vuln_count": len(findings),
        "findings": findings
    })
