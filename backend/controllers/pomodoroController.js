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