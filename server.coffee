express = require 'express'
services = require './routes/services'
fs = require 'fs'

models_path = __dirname + '/models'

fs.readdirSync(models_path).forEach((file) ->
  require(models_path+'/'+file)
)

app = express()

app.post('/user', services.findOrCreateUser)

app.post('/createGame', services.createGame)
app.post('/createRandomGame', services.createRandomGame)
app.get('/games', services.getGames)

app.get('/getPrompts', services.getPrompts)

app.post('/makeMove', services.makeMove)
app.post('/correctAnswer', services.correctAnswer)
app.post('/giveUp', services.giveUp)
 
app.listen 3000
console.log 'Listening on port 3000...'