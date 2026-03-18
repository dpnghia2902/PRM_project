const express = require("express");
const router = express.Router();
const auth = require("../middleware/authMiddleware");
const controller = require("../controllers/pomodoroController");

router.post("/", auth, controller.createPomodoro);
router.get("/", auth, controller.getPomodoros);

/// ADD THESE
router.get("/today", auth, controller.todayStats);
router.get("/week", auth, controller.weekStats);

module.exports = router;