const express = require("express");
const router = express.Router();
const auth = require("../middleware/authMiddleware");
const admin = require("../middleware/adminMiddleware");
const { getUsersReport, getLeaderboard, deleteUser, updateUserRole } = require("../controllers/adminController");

router.get("/users", auth, admin, getUsersReport);
router.get("/leaderboard", auth, admin, getLeaderboard);
router.delete("/users/:id", auth, admin, deleteUser);
router.put("/users/:id/role", auth, admin, updateUserRole);

module.exports = router;
