from flask import Blueprint, jsonify
import socket
import threading

network_bp = Blueprint('network', __name__)

# Common ports to scan
COMMON_PORTS = {
    21: "FTP",
    22: "SSH",
    80: "HTTP",
    443: "HTTPS",
    3306: "MySQL",
    5000: "Flask (Dev)",
    8080: "HTTP Proxy"
}

@network_bp.route('/scan', methods=['POST'])
def scan_network():
    # In a real tool, we might scan the user's subnet. 
    # For safety/demo, we scan localhost or a specific IP if provided, restricted to safe ports.
    
    target_ip = "127.0.0.1" 
    open_ports = []

    def check_port(port, service):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(0.5)
        result = sock.connect_ex((target_ip, port))
        if result == 0:
            open_ports.append({"port": port, "service": service, "status": "Open"})
        sock.close()

    threads = []
    for port, service in COMMON_PORTS.items():
        t = threading.Thread(target=check_port, args=(port, service))
        threads.append(t)
        t.start()
    
    for t in threads:
        t.join()

    # Add a mock "Unknown Device" for flavor if on localhost
    devices = [
        {"ip": "127.0.0.1", "name": "Localhost (This Device)", "type": "Workstation"},
        {"ip": "192.168.1.1", "name": "Gateway/Router", "type": "Network Device"}
    ]

    return jsonify({
        "target": target_ip,
        "open_ports": open_ports,
        "devices": devices
    })
