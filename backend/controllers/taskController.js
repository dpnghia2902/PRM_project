const Task = require("../models/Task");

exports.createTask = async (req, res) => {
  try {

    const { title, totalPomodoro } = req.body;

    const task = await Task.create({
      userId: req.user.id || req.user._id,
      title: title,
      totalPomodoro: totalPomodoro ?? 1,
      completedPomodoro: 0,
      completed: false
    });

    res.json(task);

  } catch (error) {
    console.log(error);
    res.status(500).json({ message: error.message });
  }
};


// get all tasks
exports.getTasks = async (req, res) => {
  try {

    const tasks = await Task.find({ userId: req.user.id });

    res.json(tasks);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


// update task
exports.updateTask = async (req, res) => {
  try {

    const { id } = req.params;

    const task = await Task.findByIdAndUpdate(
      id,
      req.body,
      { new: true }
    );

    res.json(task);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


// delete task
exports.deleteTask = async (req, res) => {
  try {

    const { id } = req.params;

    await Task.findByIdAndDelete(id);

    res.json({ message: "Task deleted" });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


// update pomodoro progress
exports.updatePomodoro = async (req, res) => {
  try {

    const { id } = req.params;

    const task = await Task.findOne({
      _id: id,
      userId: req.user.id || req.user._id
    });

    if (!task) {
      return res.status(404).json({ message: "Task not found" });
    }

    task.completedPomodoro += 1;

    if (task.completedPomodoro >= task.totalPomodoro) {
      task.completed = true;
    }

    await task.save();

    res.json(task);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};