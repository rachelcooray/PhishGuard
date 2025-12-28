import pandas as pd
import numpy as np
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
import re
import os

# 1. Generate Dummy Data
def generate_data(n=1000):
    data = []
    
    # Safe URLs
    safe_domains = ['google.com', 'facebook.com', 'amazon.com', 'wikipedia.org', 'github.com', 'stackoverflow.com', 'reddit.com', 'cnn.com', 'bbc.co.uk']
    for _ in range(n // 2):
        domain = np.random.choice(safe_domains)
        url = f"https://www.{domain}/{'a'*np.random.randint(5, 15)}"
        data.append({'url': url, 'label': 0}) # 0 = Safe
        
    # Phishing URLs
    phish_keywords = ['login', 'verify', 'update', 'secure', 'account', 'banking']
    for _ in range(n // 2):
        domain = np.random.choice(safe_domains)
        keyword = np.random.choice(phish_keywords)
        # Typo-squatting or weird subdomains
        if np.random.random() > 0.5:
            url = f"http://{keyword}-{domain}-security.com/login"
        else:
            url = f"http://{np.random.randint(100, 999)}.{np.random.randint(100, 999)}.1.1/{keyword}"
            
        data.append({'url': url, 'label': 1}) # 1 = Phishing
        
    return pd.DataFrame(data)

# 2. Feature Extractor
def extract_features(url):
    features = {}
    
    # Structural features
    features['length'] = len(url)
    features['dot_count'] = url.count('.')
    features['has_https'] = 1 if 'https' in url else 0
    features['has_ip'] = 1 if re.search(r'(\d{1,3}\.){3}\d{1,3}', url) else 0
    features['at_symbol'] = 1 if '@' in url else 0
    features['digit_count'] = sum(c.isdigit() for c in url)
    
    return features

# 3. Train
def train():
    print("Generating data...")
    df = generate_data(2000)
    
    print("Extracting features...")
    features_list = [extract_features(url) for url in df['url']]
    X = pd.DataFrame(features_list)
    y = df['label']
    
    # Train/Test Split
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    print("Training Random Forest...")
    clf = RandomForestClassifier(n_estimators=100, random_state=42)
    clf.fit(X_train, y_train)
    
    print(f"Accuracy: {clf.score(X_test, y_test):.2f}")
    
    # Save Model
    os.makedirs(os.path.dirname(__file__), exist_ok=True)
    model_path = os.path.join(os.path.dirname(__file__), 'phishing_model.pkl')
    joblib.dump(clf, model_path)
    print(f"Model saved to {model_path}")

if __name__ == "__main__":
    train()
