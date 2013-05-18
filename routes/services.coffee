mongo = require('mongodb')
url = require('url')
ObjectID = require('mongodb').ObjectID
querystring = require('querystring')
mongoose = require('mongoose')
ObjectId = require('mongoose').Types.ObjectId
fs = require('fs')

User = require('../models/user')
Game = require('../models/game')
Move = require('../models/move')
Prompt = require('../models/prompt')
 
Server = mongo.Server
Db = mongo.Db
BSON = mongo.BSONPure
 
server = new Server('localhost', 27017, {auto_reconnect: true})
db = new Db('run', server, {safe:false})

mongoose.connect('mongodb://localhost:27017/run')
db = mongoose.connection
db.on('error', console.error.bind(console, 'connection error:'))
db.once('open', () -> console.log "YAY")
 
db.open((err, db) -> 
  if(!err)
    console.log("Connected to 'run' database")
  else
    console.log("Error connecting to database: " + err)
)

exports.findAllUsers = (req, res) ->
  console.log "Getting all users"
  db.collection('users', (err, collection) ->
    collection.find().toArray((err, items) ->
      res.send items
    )
  )

exports.findOrCreateUser = (req, res) ->

  newUser = req.query
  console.log("Find or insert user with Facebook ID: " + newUser.facebookId)
  newUser.facebookId = parseInt(newUser.facebookId)

  User.findAndModify(
    { facebookId: newUser.facebookId },
    [['_id','asc']],      
    { facebookId: newUser.facebookId, name: newUser.name }, 
    { new: true, upsert: true},
    (err, user) ->
      if (err)
        console.log(err)
      else
        console.log('Created user: ' + JSON.stringify(user))
        res.send user
  )    


exports.createRandomGame = (req, res) ->
  player1Id = req.query.user
  player1 = null

  User.findByFacebookId(player1Id, (err, player) ->
    player1 = player

    User.findRandom(player1Id, (player) ->      
      player2 = player

      Game.create( 
        { "creator": new ObjectId(player1._id.toString()), "player1": new ObjectId(player1._id.toString()), "player2": ObjectId(player2._id.toString()), "points": 0},
        (err, game) ->
          if (err)
            console.log err
          else
            console.log('Created game: ' + JSON.stringify(game)); 

            Game.findOne( { _id: game._id } ).populate("player1").populate("player2").exec(
              (err, games) ->
                if (err)
                  console.log err
                else
                  console.log game
                  res.send games                     
            )
      )
    )
  )

exports.createGame = (req, res) ->
  player1Id = req.query.user
  player1 = null
  player2Id = req.query.player2
  player2 = null  

  User.findByFacebookId(player1Id, (err, player) ->
    player1 = player

    User.findByFacebookId(player2Id, (err, player) ->
      player2 = player

      Game.create( 
        { "creator": new ObjectId(player1._id.toString()), "player1": new ObjectId(player1._id.toString()), "player2": ObjectId(player2._id.toString()), "points": 0},
        (err, game) ->
          if (err)
            console.log err
          else
            console.log('Created game: ' + JSON.stringify(game)); 

            Game.findOne( { _id: game._id } ).populate("player1").populate("player2").exec(
              (err, games) ->
                if (err)
                  console.log err
                else
                  console.log game
                  res.send games                     
            )
      )
    )
  )

exports.getGames = (req, res) ->

  userId = req.query.user
  oid = new ObjectId(userId) 

  console.log "Getting games"

  Game.find().or( [ { player1: oid }, { player2: oid } ] ).populate("player1").populate("player2").populate("lastMove").exec(
    (err, games) ->
      if (err)
        console.log err
      else
        console.log games
        res.send games                     
  )        

exports.makeMove = (req, res) ->

  console.log "Making move"

  console.log req.query

  userId = new ObjectId(req.query.user)
  gameId = new ObjectId(req.query.game)
  promptId = new ObjectId(req.query.prompt)
  word = req.query.promptWord
  points = req.query.promptPoints
  imageUrl = req.query.image

  Move.create(
    { player: userId, game: gameId, prompt: promptId, word: word, points: points, image: imageUrl },
    (err, move) ->
      console.log "Saved move"
      if err
        console.log err
        res.send 500
      else
        Game.update( { _id: gameId }, { $set: { lastMove: move._id } }, (err, num) ->
          console.log "Saved game"
          if err
            console.log err
            res.send 500
          else
            console.log "Success"
            res.send 200 )
  )

exports.getPrompts = (req, res) ->

  Prompt.findRandomForEachPointValue( (prompts) ->
    res.send prompts
  )

guessPrompt = (move, res) ->
  moveId = new ObjectId(move)
  Move.update( { _id: moveId }, { $set: { guessed: true } }, (err, num) ->
    if err
      console.log err
      res.send 500
    else
      res.send 200 )

exports.correctAnswer = (req, res) ->

  gameId = new ObjectId(req.query.game)
  points = parseInt(req.query.points)

  Game.update( { _id: gameId }, { $inc: { points: points } }, (err, num) ->
    if err
      console.log err
      res.send 500
    else
      guessPrompt(req.query.move, res) )

exports.giveUp = (req, res) ->

  gameId = new ObjectId(req.query.game)

  Game.update( { _id: gameId }, { $set: { points: 0 } }, (err, num) ->
    if err
      console.log err
      res.send 500
    else
      guessPrompt(req.query.move, res) )