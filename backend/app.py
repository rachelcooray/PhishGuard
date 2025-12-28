from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from models import db
from datetime import timedelta
import os

app = Flask(__name__)

# Config
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///phishguard.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['JWT_SECRET_KEY'] = 'super-secret-key-change-this-in-prod' # Change for prod
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(days=1)

CORS(app)
db.init_app(app)
jwt = JWTManager(app)

from models.user import User
from models.module import Module
from models.vault import VaultEntry
from models.quiz import Quiz

with app.app_context():
    db.create_all()

from api.pass_checker import password_bp
from api.url_scanner import url_bp
from api.auth import auth_bp
from api.learning import learning_bp
from api.screenshot import screenshot_bp
from api.breach import breach_bp
from api.malware import malware_bp
from api.vuln import vuln_bp
from api.twofa import twofa_bp
from api.vault import vault_bp
from api.email_analysis import email_analysis_bp
from api.network_scan import network_bp
from api.log_analyzer import log_bp
from api.advanced_tools import threat_bp, phish_sim_bp
from api.gamification import gamification_bp

app.register_blueprint(password_bp, url_prefix='/api/password')
app.register_blueprint(url_bp, url_prefix='/api/url')
app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(learning_bp, url_prefix='/api/learning')
app.register_blueprint(screenshot_bp, url_prefix='/api/screenshot')
app.register_blueprint(breach_bp, url_prefix='/api/breach')
app.register_blueprint(malware_bp, url_prefix='/api/malware')
app.register_blueprint(vuln_bp, url_prefix='/api/vuln')
app.register_blueprint(twofa_bp, url_prefix='/api/twofa')
app.register_blueprint(vault_bp, url_prefix='/api/vault')
app.register_blueprint(email_analysis_bp, url_prefix='/api/email')
app.register_blueprint(network_bp, url_prefix='/api/network')
app.register_blueprint(log_bp, url_prefix='/api/logs')
app.register_blueprint(threat_bp, url_prefix='/api/threats')
app.register_blueprint(phish_sim_bp, url_prefix='/api/phish_sim')
app.register_blueprint(gamification_bp, url_prefix='/api/gamification')

@app.route('/')
def home():
    return jsonify({"message": "PhishGuard Backend is RUNNING", "status": "active"})

if __name__ == '__main__':
    app.run(debug=True, port=5000)
