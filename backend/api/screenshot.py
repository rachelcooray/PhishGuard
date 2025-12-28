from flask import Blueprint, request, jsonify
import pytesseract
from PIL import Image
import re
import os
from api.url_scanner import is_suspicious

screenshot_bp = Blueprint('screenshot', __name__)

# Configure upload folder
UPLOAD_FOLDER = os.path.join(os.path.dirname(__file__), '../uploads')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@screenshot_bp.route('/scan', methods=['POST'])
def scan_screenshot():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400
    
    file = request.files['image']
    if file.filename == '':
        return jsonify({"error": "No file selected"}), 400

    filepath = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filepath)

    try:
        # 1. OCR
        text = pytesseract.image_to_string(Image.open(filepath))
        
        # 2. Extract URLs
        # Regex to find urls
        url_pattern = r'(https?://[^\s]+)|(www\.[^\s]+)|([a-zA-Z0-9-]+\.[a-zA-Z0-9-]+\.[a-zA-Z]{2,})'
        found_urls = [x[0] or x[1] or x[2] for x in re.findall(url_pattern, text)]
        
        # Clean URLs
        clean_urls = []
        for u in found_urls:
            if not u.startswith('http'):
                clean_urls.append(f'http://{u}')
            else:
                clean_urls.append(u)

        # 3. Analyze URLs
        results = []
        for url in clean_urls:
            analysis = is_suspicious(url)
            results.append({
                "url": url,
                "analysis": analysis
            })
            
        return jsonify({
            "text_detected": text[:500] + "..." if len(text) > 500 else text,
            "urls_found": len(results),
            "results": results
        })

    except Exception as e:
        return jsonify({"error": str(e), "hint": "Is Tesseract installed?"}), 500
    finally:
        if os.path.exists(filepath):
            os.remove(filepath)
