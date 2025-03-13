import dotenv from "dotenv";
dotenv.config();
import express from "express";
import pkg from "pg";
const { Pool } = pkg;
import OpenAI from "openai";
import { zodResponseFormat } from "openai/helpers/zod";
import { z } from "zod";

const app = express();
const port = process.env.PORT || 3000;

// Set up PostgreSQL connection pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// Middleware
app.use(express.json());

// Test route
app.get("/", (req, res) => {
  res.send("AI task generation service is running");
});

app.post("/generate-task", async (req, res) => {
  const { user_id, prompt } = req.body;

  const Task = z.object({
    title: z.string(),
    description: z.string(),
  });

  const messages = [
    {
      role: "system",
      content: `You are a task generation assistant. Generate tasks in a structured format.
      Title should be short yet still descriptive and the description should be detailed`,
    },
    {
      role: "user",
      content: prompt,
    },
  ];

  const completion = await openai.beta.chat.completions.parse({
    model: "gpt-4o-mini",
    messages,
    response_format: zodResponseFormat(Task, "task"),
  });

  const task = completion.choices[0].message.parsed;
  console.log(task);

  try {
    const result = await pool.query(
      "INSERT INTO tasks (user_id, title, description) VALUES ($1, $2, $3) RETURNING *",
      [user_id, task.title, task.description],
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
});

// Start server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
