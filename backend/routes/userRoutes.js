const express = require("express");
const upload = require("../middleware/upload");
const User = require("../models/User");
const userController = require("../controllers/userController");
const auth = require("../middleware/authMiddleware");

const router = express.Router();

/* profile */
router.get("/profile", auth, userController.getProfile);
router.put("/profile", auth, userController.updateProfile);

/* upload avatar */
router.put("/:id/avatar", auth, upload.single("avatar"), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: "No file uploaded" });
    }

    // đường dẫn public
    const avatarPath = `/uploads/${req.file.filename}`;

    // update user avatar
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { avatar: avatarPath },
      { new: true } // trả user mới
    );

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // trả JSON chuẩn cho Flutter
    res.json({
      message: "Avatar uploaded successfully",
      avatar: avatarPath,
      userId: user._id,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Upload avatar failed" });
  }
});

module.exports = router;