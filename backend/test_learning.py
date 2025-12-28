import unittest
import json
import sys
import os

# Add backend to path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import app, db
from models.module import Module

class LearningTest(unittest.TestCase):
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

    def test_seed_and_fetch(self):
        # 1. Seed
        res_seed = self.app.post('/api/learning/seed')
        self.assertEqual(res_seed.status_code, 201)

        # 2. Fetch All
        res_list = self.app.get('/api/learning/modules')
        data_list = json.loads(res_list.data)
        self.assertEqual(len(data_list), 3)
        self.assertEqual(data_list[0]['title'], 'Phishing 101')
        
        # 3. Fetch Detail
        module_id = data_list[0]['id']
        res_detail = self.app.get(f'/api/learning/modules/{module_id}')
        data_detail = json.loads(res_detail.data)
        self.assertIn('content', data_detail)
        self.assertTrue(data_detail['content'].startswith('# Phishing 101'))

if __name__ == '__main__':
    unittest.main()
