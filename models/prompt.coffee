mongoose = require('mongoose')
Schema = mongoose.Schema

promptSchema = new Schema({
  word: { type: String, required: true },
  points: { type: Number, required: true }
})

promptSchema.statics.findRandomForPointValue = (points, callback) ->
  console.log("Finding random for: " + points)
  this.model("Prompt").count( { points: points },
    (err, count) =>
      if err
        console.log err
      else
        rand = Math.floor(Math.random() * count)
        this.findOne( { points: points } ).skip(rand).exec(callback)
  )

promptSchema.statics.findRandomForEachPointValue = (callback) ->
  Model = this
  prompts = []

  Model.findRandomForPointValue(1,
    (err, prompt) =>       
      prompts.push prompt
      if err
        console.log err
      else
        Model.findRandomForPointValue(2,
          (err, prompt) => 
            prompts.push prompt
            if err
              console.log err
            else
              Model.findRandomForPointValue(3, 
                (err, prompt) => 
                  prompts.push prompt
                  if err
                    console.log err
                  else
                    callback(prompts))))

module.exports = mongoose.model("Prompt", promptSchema)