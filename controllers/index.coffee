cache = require '../logic/cache'

exports.facebook = require './facebook'

exports.root = (request, response) ->
  cache.get 0, 24, (err, reply) ->
    if reply.length > 0
      buffer = ''
      buffer += item + '<br>' for item in reply
      response.send(buffer)
    else
      response.send('Nothing to see here.')
