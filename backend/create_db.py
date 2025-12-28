from app import app, db
from models.user import User
from models.module import Module
import os

print(f"DB URI: {app.config['SQLALCHEMY_DATABASE_URI']}")
print(f"CWD: {os.getcwd()}")

with app.app_context():
    try:
        db.create_all()
        print("Tables created successfully.")
    except Exception as e:
        print(f"Error creating tables: {e}")

    # Verify
    try:
        from sqlalchemy import inspect
        inspector = inspect(db.engine)
        print("Tables:", inspector.get_table_names())
    except Exception as e:
        print(f"Error inspecting tables: {e}")
