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
  res.send("stats service is running");
});

// Get all stats for a user
app.get("/stats/:user_id", async (req, res) => {
  const { user_id } = req.params;
  try {
    const result = await pool.query(
      "SELECT COUNT(*) FROM tasks WHERE user_id = $1 AND completed = true",
      [user_id],
    );

    const completedCount = parseInt(result.rows[0].count);

    res.json({ tasks_completed: completedCount });
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
});

// Start server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
