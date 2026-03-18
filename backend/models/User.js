const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({

  fullName: {
    type: String,
    required: true
  },

  email: {
    type: String,
    unique: true
  },

  password: String,

  gender: {
    type: String,
    enum: ["male","female"],
    default: "male"
  },

  avatar: {
    type: String,
    default: ""
  },

  createdAt: {
    type: Date,
    default: Date.now
  }

});

module.exports = mongoose.model("User", userSchema);