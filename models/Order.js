const mongoose = require("mongoose");

const orderSchema = new mongoose.Schema({

  userId: String,

  pdfId: String,

  amount: Number,

  status: {
    type: String,
    default: "pending"
  },

  createdAt: {
    type: Date,
    default: Date.now
  }

});

module.exports = mongoose.model("Order", orderSchema);
