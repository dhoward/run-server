mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

userSchema = new Schema { name: String, facebookId: Number}

userSchema.statics.findAndModify = (query, sort, doc, options, callback) ->
  return this.collection.findAndModify(query, sort, doc, options, callback)

userSchema.statics.findByFacebookId = (facebookId, callback) ->
  return this.findOne({ facebookId: facebookId }, callback)

userSchema.statics.findRandom = (userFacebookId, callback) ->
  console.log("Finding random user")

  getRandom = (count) =>
    rand = Math.floor(Math.random() * count)
    user = this.findOne().skip(rand).exec( (err, obj) -> 
      if obj.facebookId == userFacebookId
        getRandom count
      else
        callback obj
    )

  this.model("User").count( {},
    (err, count) =>
      if err
        console.log err
      else
        user = getRandom(count, callback)
  )

module.exports = mongoose.model("User", userSchema)