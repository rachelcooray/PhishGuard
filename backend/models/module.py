from . import db

class Module(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.String(500), nullable=False)
    content = db.Column(db.Text, nullable=False)
    estimated_time = db.Column(db.Integer, nullable=False) # In minutes

    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "estimated_time": self.estimated_time
        }

    def to_dict_full(self):
        data = self.to_dict()
        data["content"] = self.content
        return data
