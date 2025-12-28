import unittest
import json
import sys
import os

# Add backend to path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import app, db

class AuthTest(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True
        
        # Use in-memory DB for testing
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
        with app.app_context():
            db.create_all()

    def tearDown(self):
        with app.app_context():
            db.session.remove()
            db.drop_all()

    def test_register_and_login(self):
        # 1. Register
        res_reg = self.app.post('/api/auth/register', 
                                data=json.dumps({'email': 'test@example.com', 'password': 'pass', 'name': 'Tester'}),
                                content_type='application/json')
        data_reg = json.loads(res_reg.data)
        self.assertEqual(res_reg.status_code, 201)
        self.assertIn('token', data_reg)

        # 2. Login
        res_login = self.app.post('/api/auth/login', 
                                  data=json.dumps({'email': 'test@example.com', 'password': 'pass'}),
                                  content_type='application/json')
        data_login = json.loads(res_login.data)
        self.assertEqual(res_login.status_code, 200)
        token = data_login['token']

        # 3. Profile (Protected)
        res_profile = self.app.get('/api/auth/profile', headers={'Authorization': f'Bearer {token}'})
        data_profile = json.loads(res_profile.data)
        self.assertEqual(res_profile.status_code, 200)
        self.assertEqual(data_profile['email'], 'test@example.com')

if __name__ == '__main__':
    unittest.main()
