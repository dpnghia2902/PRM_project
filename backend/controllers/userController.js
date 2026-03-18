const User = require("../models/User");

exports.getProfile = async (req,res) => {

  const user = await User.findById(req.user.id).select("-password");

  res.json(user);

};

exports.updateProfile = async (req,res) => {

  try{

    const { fullName, gender, avatar } = req.body;

    const user = await User.findByIdAndUpdate(

      req.user.id,

      {
        fullName,
        gender,
        avatar
      },

      { new:true }

    ).select("-password");

    res.json(user);

  }
  catch(error){
    res.status(500).json({message:"Update failed"});
  }

};