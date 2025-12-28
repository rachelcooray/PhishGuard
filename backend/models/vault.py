from . import db
from datetime import datetime

class VaultEntry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    service_name = db.Column(db.String(100), nullable=False)
    username = db.Column(db.String(100), nullable=False)
    encrypted_password = db.Column(db.Text, nullable=False) # Stores bytes as hex or base64
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "service": self.service_name,
            "username": self.username,
            "created_at": self.created_at.isoformat()
        }
