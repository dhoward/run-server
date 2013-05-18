mongoose = require('mongoose')
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
UserSchema = require('./user')

gameSchema = new Schema({
  creator: { type: ObjectId, ref: "User", required: true },
  player1: { type: ObjectId, ref: "User", required: true },
  player2: { type: ObjectId, ref: "User", required: true },
  points: {type: Number, required: true},
  lastMove: { type: ObjectId, ref: "Move" }
})

module.exports = mongoose.model("Game", gameSchema)