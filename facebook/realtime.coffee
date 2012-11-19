credentials = require './credentials'
puller = require './puller'

# Verifies real-time update subscription on Facebook.
exports.verify = (request, response) ->
  if request.query['hub.mode'] != 'subscribe'
    response.send(400)
  else if request.query['hub.verify_token'] != credentials.realtime.verifyToken
    response.send(403)
  else
    response.send(request.query['hub.challenge'])

# Handles real-time activity updates on Facebook.
exports.update = (request, response) ->
  if not request.is('application/json')
    response.send(400)
  else
    try
      puller.pull(request.body)
      response.send(200)
    catch errorStatusCode
      response.send(errorStatusCode)
