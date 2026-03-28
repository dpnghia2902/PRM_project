const Pomodoro = require("../models/Pomodoro");

/// CREATE POMODORO
exports.createPomodoro = async (req, res) => {

  const { duration, taskId } = req.body;

  const pomodoro = await Pomodoro.create({
    userId: req.user.id,
    duration,
    taskId,
    completed: true
  });

  res.json(pomodoro);

};


/// GET ALL POMODORO
exports.getPomodoros = async (req, res) => {

  const list = await Pomodoro.find({
    userId: req.user.id
  });

  res.json(list);

};


/// TODAY STATS
exports.todayStats = async (req, res) => {

  const start = new Date();
  start.setHours(0,0,0,0);

  const end = new Date();
  end.setHours(23,59,59,999);

  const pomos = await Pomodoro.find({
    userId: req.user.id,
    createdAt: {
      $gte: start,
      $lte: end
    }
  });

  const totalPomodoro = pomos.length;

  const focusMinutes = pomos.reduce((sum,p)=>sum+p.duration,0);

  res.json({
    totalPomodoro,
    focusMinutes
  });

};


/// WEEK STATS
exports.weekStats = async (req,res)=>{

  const now = new Date();

  // Monday start week
  const day = now.getDay() === 0 ? 7 : now.getDay();

  const firstDay = new Date(now);
  firstDay.setDate(now.getDate() - day + 1);
  firstDay.setHours(0,0,0,0);

  const lastDay = new Date(firstDay);
  lastDay.setDate(firstDay.getDate()+7);

  const pomos = await Pomodoro.find({
    userId:req.user.id,
    createdAt:{
      $gte:firstDay,
      $lt:lastDay
    }
  });

  const week = [0,0,0,0,0,0,0];

  pomos.forEach(p=>{
    const d = new Date(p.createdAt).getDay();
    const index = d === 0 ? 6 : d-1; // Monday = 0
    week[index]++;
  });

  const totalPomodoro = pomos.length;

  const focusMinutes = pomos.reduce((sum,p)=>sum+p.duration,0);

  res.json({
    week,
    totalPomodoro,
    focusMinutes
  });

};


/// WEEK RANKING
exports.weekRank = async (req,res)=>{
  const now = new Date();
  const day = now.getDay() === 0 ? 7 : now.getDay();
  const firstDay = new Date(now);
  firstDay.setDate(now.getDate() - day + 1);
  firstDay.setHours(0,0,0,0);
  const lastDay = new Date(firstDay);
  lastDay.setDate(firstDay.getDate()+7);

  const agg = await Pomodoro.aggregate([
    {
      $match: {
        createdAt: { $gte: firstDay, $lt: lastDay }
      }
    },
    {
      $group: {
        _id: '$userId',
        totalDuration: { $sum: '$duration' },
        count: { $sum: 1 }
      }
    },
    {
      $lookup: {
        from: 'users',
        localField: '_id',
        foreignField: '_id',
        as: 'user'
      }
    },
    {
      $unwind: '$user'
    },
    {
      $project: {
        _id: 1,
        totalDuration: 1,
        count: 1,
        fullName: '$user.fullName',
        avatar: '$user.avatar'
      }
    },
    {
      $sort: { totalDuration: -1, count: -1 }
    }
  ]);

  const leaderboard = agg.map((item,index)=>({
    rank: index + 1,
    userId: item._id,
    fullName: item.fullName || "Unknown",
    avatar: item.avatar || "",
    totalDuration: item.totalDuration || 0,
    totalPomodoro: Math.floor((item.totalDuration || 0) / 25),
    focusMinutes: item.totalDuration || 0
  }));

  const me = leaderboard.find(x=>x.userId.toString() === req.user.id.toString());

  let myRank = me ? me.rank : null;
  let myTotalDuration = me ? me.totalDuration : 0;
  let myTotalPomodoro = me ? me.totalPomodoro : 0;
  let myFocus = me ? me.focusMinutes : 0;

  res.json({
    weekRank: myRank,
    weekTotalDuration: myTotalDuration,
    weekTotalPomodoro: myTotalPomodoro,
    weekFocusMinutes: myFocus,
    leaderboard: leaderboard.slice(0, 10)
  });
};

/// STREAK
exports.getStreak = async (req, res) => {
  const pomos = await Pomodoro.find({ userId: req.user.id }).sort({ createdAt: -1 });

  const dateSet = new Set();
  pomos.forEach(p => {
    const date = new Date(p.createdAt).toISOString().split('T')[0]; // YYYY-MM-DD
    dateSet.add(date);
  });

  const dates = Array.from(dateSet).sort((a, b) => new Date(b) - new Date(a)); // descending

  if (dates.length === 0) {
    return res.json({ streak: 0 });
  }

  let streak = 0;
  const latest = new Date(dates[0]);

  for (let i = 0; i < dates.length; i++) {
    const expected = new Date(latest);
    expected.setDate(latest.getDate() - i);
    const expectedStr = expected.toISOString().split('T')[0];

    if (dates[i] === expectedStr) {
      streak++;
    } else {
      break;
    }
  }

  res.json({ streak });
};