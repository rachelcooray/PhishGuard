import unittest
import json
import sys
import os

# Add backend to path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import app

class UrlTest(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_safe_url(self):
        response = self.app.post('/api/url/scan', 
                                 data=json.dumps({'url': 'https://google.com'}),
                                 content_type='application/json')
        data = json.loads(response.data)
        self.assertEqual(data['status'], 'Safe')
        self.assertEqual(len(data['flags']), 0)
        self.assertIn('ml_probability', data)

    def test_suspicious_url(self):
        # HTTP instead of HTTPS, and IP address
        response = self.app.post('/api/url/scan', 
                                 data=json.dumps({'url': 'http://192.168.1.1/login'}),
                                 content_type='application/json')
        data = json.loads(response.data)
        self.assertIn('Not using HTTPS', data['flags'])
        self.assertIn('URL contains IP address instead of domain', data['flags'])
        self.assertNotEqual(data['status'], 'Safe')

if __name__ == '__main__':
    unittest.main()
