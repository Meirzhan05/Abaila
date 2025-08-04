const mongoose = require("mongoose");

const alertSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  description: String,
  mediaUrl: String,         
  mediaType: String,        
  likes: {
    type: Number,
    default: 0
  },
  comments: {
    type: Number,
    default: 0
  },
  views: {
    type: Number,
    default: 0
  },
  type: {
    type: String,           
    required: true
  },
  location: String,
  createdAt: {
    type: Date,
    default: Date.now
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
});

const Alert = mongoose.model("Alert", alertSchema);
module.exports = Alert;
