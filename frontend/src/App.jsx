import { useState, useEffect } from "react";

const API_URL = window.__API_URL__ || "/api";

function App() {
  const [todos, setTodos] = useState([]);
  const [newTodo, setNewTodo] = useState("");
  const [loading, setLoading] = useState(true);

  const fetchTodos = async () => {
    try {
      const res = await fetch(`${API_URL}/todos`);
      const data = await res.json();
      setTodos(data);
    } catch (err) {
      console.error("Failed to fetch todos:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTodos();
  }, []);

  const addTodo = async (e) => {
    e.preventDefault();
    if (!newTodo.trim()) return;
    try {
      const res = await fetch(`${API_URL}/todos`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ title: newTodo.trim() }),
      });
      const todo = await res.json();
      setTodos([todo, ...todos]);
      setNewTodo("");
    } catch (err) {
      console.error("Failed to add todo:", err);
    }
  };

  const toggleTodo = async (id, completed) => {
    try {
      const res = await fetch(`${API_URL}/todos/${id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ completed: !completed }),
      });
      const updated = await res.json();
      setTodos(todos.map((t) => (t.id === id ? updated : t)));
    } catch (err) {
      console.error("Failed to update todo:", err);
    }
  };

  const deleteTodo = async (id) => {
    try {
      await fetch(`${API_URL}/todos/${id}`, { method: "DELETE" });
      setTodos(todos.filter((t) => t.id !== id));
    } catch (err) {
      console.error("Failed to delete todo:", err);
    }
  };

  return (
    <div style={styles.container}>
      <h1 style={styles.title}>Todo App</h1>

      <form onSubmit={addTodo} style={styles.form}>
        <input
          type="text"
          value={newTodo}
          onChange={(e) => setNewTodo(e.target.value)}
          placeholder="What needs to be done?"
          style={styles.input}
        />
        <button type="submit" style={styles.addBtn}>
          Add
        </button>
      </form>

      {loading ? (
        <p style={styles.message}>Loading...</p>
      ) : todos.length === 0 ? (
        <p style={styles.message}>No todos yet. Add one above!</p>
      ) : (
        <ul style={styles.list}>
          {todos.map((todo) => (
            <li key={todo.id} style={styles.item}>
              <label style={styles.label}>
                <input
                  type="checkbox"
                  checked={todo.completed}
                  onChange={() => toggleTodo(todo.id, todo.completed)}
                  style={styles.checkbox}
                />
                <span
                  style={{
                    ...styles.text,
                    textDecoration: todo.completed ? "line-through" : "none",
                    opacity: todo.completed ? 0.5 : 1,
                  }}
                >
                  {todo.title}
                </span>
              </label>
              <button
                onClick={() => deleteTodo(todo.id)}
                style={styles.deleteBtn}
              >
                Delete
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

const styles = {
  container: {
    maxWidth: "600px",
    margin: "40px auto",
    padding: "0 20px",
    fontFamily: "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
  },
  title: {
    textAlign: "center",
    color: "#333",
    marginBottom: "30px",
  },
  form: {
    display: "flex",
    gap: "10px",
    marginBottom: "20px",
  },
  input: {
    flex: 1,
    padding: "10px 14px",
    fontSize: "16px",
    border: "2px solid #ddd",
    borderRadius: "6px",
    outline: "none",
  },
  addBtn: {
    padding: "10px 20px",
    fontSize: "16px",
    backgroundColor: "#4CAF50",
    color: "white",
    border: "none",
    borderRadius: "6px",
    cursor: "pointer",
  },
  list: {
    listStyle: "none",
    padding: 0,
  },
  item: {
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    padding: "12px 14px",
    marginBottom: "8px",
    backgroundColor: "#f9f9f9",
    borderRadius: "6px",
    border: "1px solid #eee",
  },
  label: {
    display: "flex",
    alignItems: "center",
    gap: "10px",
    flex: 1,
    cursor: "pointer",
  },
  checkbox: {
    width: "18px",
    height: "18px",
    cursor: "pointer",
  },
  text: {
    fontSize: "16px",
    color: "#333",
  },
  deleteBtn: {
    padding: "6px 12px",
    fontSize: "14px",
    backgroundColor: "#ff4444",
    color: "white",
    border: "none",
    borderRadius: "4px",
    cursor: "pointer",
  },
  message: {
    textAlign: "center",
    color: "#888",
    fontSize: "16px",
  },
};

export default App;
