const User = require("../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

exports.register = async (req, res) => {

  try{

    const { fullName, email, password, gender, role } = req.body;

    const existingUser = await User.findOne({ email });

    if(existingUser){
      return res.status(400).json({ message: "Email already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const userRole = role === "admin" ? "admin" : "user";

    const user = await User.create({
      fullName,
      email,
      password: hashedPassword,
      gender,
      role: userRole
    });

    res.json({
      message: "User created",
      user
    });

  }
  catch(error){
    res.status(500).json({ message: "Register failed" });
  }

};

exports.login = async (req, res) => {

  const { email, password } = req.body;

  const user = await User.findOne({ email });

  if (!user)
    return res.status(400).json({ message: "User not found" });

  const match = await bcrypt.compare(password, user.password);

  if (!match)
    return res.status(400).json({ message: "Wrong password" });

  const token = jwt.sign(
    { id: user._id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: "7d" }
  );

  const userData = await User.findById(user._id).select("-password");

  res.json({
    token,
    user: userData
  });

};