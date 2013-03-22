mongoose = require('mongoose')
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
UserSchema = require('./user')

gameSchema = new Schema({
  player1: { type: ObjectId, ref: "User", required: true },
  player2: { type: ObjectId, ref: "User", required: true },
  points: {type: Number, required: true},
  lastMove: { type: ObjectId, ref: "Move" }
})

module.exports = mongoose.model("Game", gameSchema)