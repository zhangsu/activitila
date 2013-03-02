credentials = require './credentials'
puller = require './puller'

###
Pull data from Facebook based on realtime update payload.
###
handleUpdates = (payload) ->
  if not payload.object
    throw 400
  if payload.object != 'user'
    # Only accepting user updates.
    throw 404
  else if payload.entry not instanceof Array
    throw 400
  else
    for entry in payload.entry
      throw 400 unless entry.changed_fields instanceof Array
      throw 404 unless entry.uid == credentials.basic.uid

      for field in entry.changed_fields
        if field == 'feed'
          puller.pullFeed()

###
Handler for verifying real-time update subscription on Facebook.
###
exports.verify = (request, response) ->
  if request.query['hub.mode'] != 'subscribe'
    response.send(400)
  else if request.query['hub.verify_token'] != credentials.realtime.verifyToken
    response.send(403)
  else
    response.send(request.query['hub.challenge'])

###
Handler for real-time activity updates on Facebook.
###
exports.update = (request, response) ->
  if not request.is('application/json')
    response.send(400)
  else
    try
      handleUpdates(request.body)
      response.send(200)
    catch errorStatusCode
      response.send(errorStatusCode)
