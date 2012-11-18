credentials = require './credentials'

# Verifies real-time update subscription on Facebook.
exports.verify = (request, response) ->
  if request.query['hub.mode'] != 'subscribe'
    response.send(400)
  else if request.query['hub.verify_token'] != credentials.realtime.verifyToken
    response.send(403)
  else
    response.send('Subscription verified!')

# Handles real-time activity updates on Facebook.
exports.update = (request, response) ->
  response.send(200)
