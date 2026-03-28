const User = require("../models/User");
const Pomodoro = require("../models/Pomodoro");

// Admin: danh sách user + báo cáo pomodoro
exports.getUsersReport = async (req, res) => {
  try {
    const users = await User.find().select("-password");

    const now = new Date();
    const todayStart = new Date(now); todayStart.setHours(0,0,0,0);
    const todayEnd = new Date(now); todayEnd.setHours(23,59,59,999);

    const day = now.getDay() === 0 ? 7 : now.getDay();
    const weekStart = new Date(now);
    weekStart.setDate(now.getDate() - day + 1);
    weekStart.setHours(0,0,0,0);
    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekStart.getDate() + 7);

    const report = await Promise.all(users.map(async (user) => {
      const todayPomos = await Pomodoro.countDocuments({
        userId: user._id,
        createdAt: { $gte: todayStart, $lte: todayEnd }
      });

      const weekPomos = await Pomodoro.countDocuments({
        userId: user._id,
        createdAt: { $gte: weekStart, $lt: weekEnd }
      });

      const totalDuration = (await Pomodoro.aggregate([
        { $match: { userId: user._id } },
        { $group: { _id: "$userId", totalDuration: { $sum: "$duration" } } }
      ]))?.[0]?.totalDuration || 0;

      return {
        userId: user._id,
        fullName: user.fullName,
        email: user.email,
        avatar: user.avatar,
        role: user.role,
        createdAt: user.createdAt,
        todayPomos,
        weekPomos,
        totalDuration,
        totalPomodoro: Math.floor(totalDuration / 25)
      };
    }));

    res.json(report);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Admin report error" });
  }
};

// Admin: leaderboard all-time
exports.getLeaderboard = async (req, res) => {
  try {
    const agg = await Pomodoro.aggregate([
      {
        $group: {
          _id: "$userId",
          totalDuration: { $sum: "$duration" },
          totalPomos: { $sum: 1 }
        }
      },
      {
        $lookup: {
          from: "users",
          localField: "_id",
          foreignField: "_id",
          as: "user"
        }
      },
      { $unwind: "$user" },
      {
        $project: {
          _id: 0,
          userId: "$_id",
          fullName: "$user.fullName",
          avatar: "$user.avatar",
          totalDuration: 1,
          totalPomos: 1,
          calcPomodoro: { $floor: { $divide: ["$totalDuration", 25] } }
        }
      },
      { $sort: { totalDuration: -1 } }
    ]);

    res.json(agg);

  } catch(error) {
    console.error(error);
    res.status(500).json({ message: "Leaderboard error"});
  }
};

// Admin: xóa user
exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    await User.findByIdAndDelete(id);
    res.json({ message: "User deleted" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Delete failed" });
  }
};

// Admin: thay đổi role user
exports.updateUserRole = async (req, res) => {
  try {
    const { id } = req.params;
    const { role } = req.body;
    if (!["user", "admin"].includes(role)) {
      return res.status(400).json({ message: "Invalid role" });
    }
    const user = await User.findByIdAndUpdate(id, { role }, { new: true }).select("-password");
    res.json(user);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Update role failed" });
  }
};