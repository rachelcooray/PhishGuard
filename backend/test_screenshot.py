import unittest
from unittest.mock import patch, MagicMock
import json
import io
import sys
import os

# Add backend to path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import app

class ScreenshotTest(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    @patch('api.screenshot.pytesseract.image_to_string')
    @patch('api.screenshot.Image.open')
    def test_scan_screenshot(self, mock_img_open, mock_ocr):
        # Mock OCR result
        mock_ocr.return_value = "Hey check this out http://evil-phishing-site.com/login it is cool."
        
        # Create dummy image file
        data = {
            'image': (io.BytesIO(b"dummy image data"), 'test.png')
        }
        
        response = self.app.post('/api/screenshot/scan', data=data, content_type='multipart/form-data')
        
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        
        self.assertIn('text_detected', data)
        self.assertIn('evil-phishing-site.com', data['text_detected'])
        self.assertGreater(data['urls_found'], 0)
        
        # Check if the URL was flagged
        results = data['results']
        self.assertEqual(results[0]['url'], 'http://evil-phishing-site.com/login')
        # Depending on ML/Rule state, it might vary, but we expect analysis to be present
        self.assertIn('status', results[0]['analysis'])

    def test_no_file(self):
        response = self.app.post('/api/screenshot/scan')
        self.assertEqual(response.status_code, 400)

if __name__ == '__main__':
    unittest.main()
