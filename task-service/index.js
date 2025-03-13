import dotenv from "dotenv";
dotenv.config();
import express from "express";
import pkg from "pg";
const { Pool } = pkg;

const app = express();
const port = process.env.PORT || 3000;

// Set up PostgreSQL connection pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Middleware
app.use(express.json());

// Test route
app.get("/", (req, res) => {
  res.send("Task service is running");
});

app.post("/tasks", async (req, res) => {
  const { user_id, title, description } = req.body;
  try {
    const result = await pool.query(
      "INSERT INTO tasks (user_id, title, description) VALUES ($1, $2, $3) RETURNING *",
      [user_id, title, description],
    );
    res.status(201).json(result.rows[0]);
    console.log(`User ${user_id} created a new task`);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
});

// Get all tasks for a user
app.get("/tasks/:user_id", async (req, res) => {
  const { user_id } = req.params;
  try {
    const result = await pool.query(
      "SELECT * FROM tasks WHERE user_id = $1 AND hidden = false",
      [user_id],
    );
    res.json(result.rows);
    console.log(`Tasks of user ${user_id} requested`);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
});

// Update a task
app.put("/tasks/:id", async (req, res) => {
  const { id } = req.params;
  const { title, description, completed } = req.body;
  try {
    const result = await pool.query(
      "UPDATE tasks SET title = $1, description = $2, completed = $3 WHERE id = $4 RETURNING *",
      [title, description, completed, id],
    );
    if (result.rows.length === 0) return res.status(404).send("Task not found");
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
});

app.delete("/tasks/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      "UPDATE tasks SET hidden = true WHERE id = $1 RETURNING *",
      [id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Task not found" });
    }

    res.json({ message: "Task hidden successfully", task: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
});

// Start server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
