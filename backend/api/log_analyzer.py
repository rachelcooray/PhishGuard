from flask import Blueprint, request, jsonify
import pandas as pd
import io
import re

log_bp = Blueprint('logs', __name__)

@log_bp.route('/analyze', methods=['POST'])
def analyze_logs():
    if 'file' not in request.files:
        return jsonify({"error": "No file uploaded"}), 400
    
    file = request.files['file']
    if not file:
        return jsonify({"error": "Empty file"}), 400

    try:
        # Simple parsing logic for Common Log Format (CLF)
        # 127.0.0.1 - - [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326
        
        content = file.read().decode('utf-8')
        lines = content.splitlines()
        
        data = []
        log_pattern = re.compile(r'(?P<ip>\d+\.\d+\.\d+\.\d+) .+? \[(?P<timestamp>.+?)\] "(?P<request>.+?)" (?P<status>\d+) (?P<size>\d+|-)')
        
        for line in lines:
            match = log_pattern.match(line)
            if match:
                data.append(match.groupdict())
        
        if not data:
            return jsonify({"error": "Could not parse log format. Ensure standard CLF."}), 400

        df = pd.DataFrame(data)
        
        # Analysis 1: Count Status Codes
        status_counts = df['status'].value_counts().to_dict()
        
        # Analysis 2: Detect Brute Force (High 401/403 from single IP)
        suspicious_ips = []
        if 'status' in df.columns and 'ip' in df.columns:
            error_logs = df[df['status'].isin(['401', '403'])]
            if not error_logs.empty:
                ip_counts = error_logs['ip'].value_counts()
                for ip, count in ip_counts.items():
                    if count > 5: # Threshold
                        suspicious_ips.append({"ip": ip, "failed_attempts": int(count)})

        return jsonify({
            "total_lines": len(df),
            "status_distribution": status_counts,
            "suspicious_activity": suspicious_ips,
            "message": "Log analysis complete."
        })

    except Exception as e:
        return jsonify({"error": f"Analysis failed: {str(e)}"}), 500
