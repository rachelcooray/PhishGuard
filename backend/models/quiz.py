from models import db

class Quiz(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    module_id = db.Column(db.Integer, db.ForeignKey('module.id'), nullable=False)
    question = db.Column(db.String(500), nullable=False)
    options = db.Column(db.JSON, nullable=False)  # List of strings
    correct_index = db.Column(db.Integer, nullable=False)

    def to_dict(self):
        return {
            "id": self.id,
            "module_id": self.module_id,
            "question": self.question,
            "options": self.options,
            "correct_index": self.correct_index
        }
