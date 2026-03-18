const express = require("express");
const cors = require("cors");
require("dotenv").config();

const connectDB = require("./config/db");

const app = express();

connectDB();

app.use(cors());
app.use(express.json());

app.use("/api/auth", require("./routes/authRoutes"));
app.use("/api/user", require("./routes/userRoutes"));
app.use("/api/pomodoro", require("./routes/pomodoroRoutes"));
app.use("/api/tasks", require("./routes/taskRoutes"));

app.listen(5000, () => {
  console.log("Server running on port 5000");
});