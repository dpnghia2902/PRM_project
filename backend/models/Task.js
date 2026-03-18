const mongoose = require("mongoose");

const taskSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User"
  },

  title: {
    type: String,
    required: true
  },

  totalPomodoro: {
    type: Number,
    default: 1
  },

  completedPomodoro: {
    type: Number,
    default: 0
  },

  completed: {
    type: Boolean,
    default: false
  }

});

module.exports = mongoose.model("Task", taskSchema);