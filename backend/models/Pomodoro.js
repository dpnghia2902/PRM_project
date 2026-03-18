const mongoose = require("mongoose");

const pomodoroSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User"
  },
  taskId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Task",
    default: null
  },
  duration: Number, // phút
  completed: Boolean,
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model("Pomodoro", pomodoroSchema);