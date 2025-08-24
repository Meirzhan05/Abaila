const mongoose = require("mongoose");

const alertSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  description: String,
  media: [
    {
      type: String,
      trim: true,
      maxlength: 2048 }
  ],
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
  location: {
    type: {
      type: String, // "Point"
      enum: ["Point"],
      required: true
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      required: true
    }
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
});

const Alert = mongoose.model("Alert", alertSchema);
module.exports = Alert;
