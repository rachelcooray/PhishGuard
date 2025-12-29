# PhishGuard 🛡️

PhishGuard is a comprehensive cybersecurity mobile application designed to empower users with protection, analysis, and education against digital threats. Combining rule-based heuristics, machine learning, and gamified education, it serves as a personal "Cyber Sentinel."

## 🚀 Features

### **1. Core Protection**
- **🔍 Phishing URL Scanner**: Hybrid analyis using Rule-based checks + **Random Forest ML** to probability scores.
- **📷 QR Code Inspect**: Safely scans QR codes and checks the destination before you click.
- **🖼️ Screenshot Forensics**: Extracts text from suspicious screenshots (OCR) to find hidden links.
- **🔐 Password Check**: Entropy analysis to estimate crack times (zxcvbn logic) and breach status.

### **2. Advanced Tools**
- **📧 Email Analyzer**: NLP-powered analysis to detect urgency and phishing keywords.
- **🕵️ Data Breach Checker**: k-anonymity checks against the *HaveIBeenPwned* database.
- **📡 Network Scanner**: Simulated local port scanning to identify open vulnerabilities.
- **📝 Log Auditor**: Parses server logs (Apache/Nginx) to detect brute force patterns.
- **🦠 Malware Scanner**: File hashing (MD5/SHA256) checked against a mock threat database.

### **3. Privacy & Safety**
- **🔑 Secure Vault**: Encrypted local storage for sensitive credentials.
- **🛡️ 2FA Simulator**: Interactive demo of Time-based One-Time Password (TOTP) generation.
- **🌍 Threat Dashboard**: Real-time visualization of global cyber attack trends.
- **🎣 Phishing Simulator**: Launch mock campaigns to test user awareness.

### **4. Gamified Education**
- **📚 Learning Hub**: Rich markdown lessons on Social Engineering, Hygiene, and more.
- **🏆 Quizzes**: Interactive assessments integrated into every module.
- **🎮 XP & Levels**: Users earn XP and level up (e.g., "Cyber Sentinel") by using tools.

---

## 🛠️ Tech Stack
- **Frontend**: Flutter (Dart) - Grid Dashboard, Google Fonts, Fl_Chart.
- **Backend**: Flask (Python) - JWT Auth, SQLAlchemy, Pandas, Scikit-Learn.
- **AI/ML**: Random Forest (URL), Pytesseract (OCR), TextBlob/NLTK (NLP).
- **Database**: SQLite (Local Dev), PostgreSQL ready.

---

## 🏁 Getting Started

### 1. Backend Setup
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Seed Database & Train Model
python3 ml/train.py
