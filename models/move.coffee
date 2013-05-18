mongoose = require('mongoose')
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
UserSchema = require('./game')

moveSchema = new Schema({
  player: { type: ObjectId, ref: "User", required: true },
  game: { type: ObjectId, ref: "Game", required: true },
  prompt: { type: ObjectId, ref: "Prompt", required: true },
  points: { type: Number, required: true },
  word: { type: String, required: true },
  image: { type: String, required: true },
  guessed: { type: Boolean }
})

module.exports = mongoose.model("Move", moveSchema)