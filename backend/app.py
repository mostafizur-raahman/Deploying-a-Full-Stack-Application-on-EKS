import os
from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

app = Flask(__name__)
CORS(app)

app.config["SQLALCHEMY_DATABASE_URI"] = os.environ.get(
    "DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/tododb"
)
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)


class Todo(db.Model):
    __tablename__ = "todos"

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    completed = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "completed": self.completed,
            "created_at": self.created_at.isoformat(),
        }


with app.app_context():
    db.create_all()


@app.route("/health")
def health():
    return jsonify({"status": "ok"})


@app.route("/api/todos", methods=["GET"])
def get_todos():
    todos = Todo.query.order_by(Todo.created_at.desc()).all()
    return jsonify([t.to_dict() for t in todos])


@app.route("/api/todos", methods=["POST"])
def create_todo():
    data = request.get_json()
    if not data or not data.get("title"):
        return jsonify({"error": "title is required"}), 400
    todo = Todo(title=data["title"])
    db.session.add(todo)
    db.session.commit()
    return jsonify(todo.to_dict()), 201


@app.route("/api/todos/<int:todo_id>", methods=["PUT"])
def update_todo(todo_id):
    todo = Todo.query.get_or_404(todo_id)
    data = request.get_json()
    if "title" in data:
        todo.title = data["title"]
    if "completed" in data:
        todo.completed = data["completed"]
    db.session.commit()
    return jsonify(todo.to_dict())


@app.route("/api/todos/<int:todo_id>", methods=["DELETE"])
def delete_todo(todo_id):
    todo = Todo.query.get_or_404(todo_id)
    db.session.delete(todo)
    db.session.commit()
    return jsonify({"message": "deleted"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
