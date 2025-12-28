import unittest
import json
import sys
import os

# Add backend to path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import app

class PasswordTest(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_weak_password(self):
        response = self.app.post('/api/password/check-strength', 
                                 data=json.dumps({'password': '123'}),
                                 content_type='application/json')
        data = json.loads(response.data)
        self.assertEqual(data['score'], 0)
        self.assertIn('warning', data)

    def test_strong_password(self):
        response = self.app.post('/api/password/check-strength', 
                                 data=json.dumps({'password': 'CorrectHorseBatteryStaple123!'}),
                                 content_type='application/json')
        data = json.loads(response.data)
        self.assertEqual(data['score'], 4)

if __name__ == '__main__':
    unittest.main()
