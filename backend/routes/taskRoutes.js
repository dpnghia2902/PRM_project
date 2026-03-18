const express = require("express");
const router = express.Router();

const auth = require("../middleware/authMiddleware");
const controller = require("../controllers/taskController");

router.post("/", auth, controller.createTask);
router.get("/", auth, controller.getTasks);
router.put("/:id", auth, controller.updateTask);
router.delete("/:id", auth, controller.deleteTask);

// update pomodoro progress
router.patch("/:id/pomodoro", auth, controller.updatePomodoro);

module.exports = router;