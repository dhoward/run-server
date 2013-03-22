mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

userSchema = new Schema { name: String, facebookId: Number}

userSchema.statics.findAndModify = (query, sort, doc, options, callback) ->
  return this.collection.findAndModify(query, sort, doc, options, callback)

userSchema.statics.findByFacebookId = (facebookId, callback) ->
  return this.find({ facebookId: facebookId }, callback)

module.exports = mongoose.model("User", userSchema)