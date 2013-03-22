findUsersByFacebookIds = (facebookIdArray) ->
  console.log "USERSERVICE"
  db.collection('users', (err, collection) ->
    var userId = collection.find(
      { facebookId: 1 },
      (err, user) ->
        if (err)
          console.log err
        else
          res.send user
    )        
  )