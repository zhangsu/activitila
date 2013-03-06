cache = require '../logic/cache'

exports.facebook = require './facebook'

exports.root = (request, response) ->
  cache.get 0, 24, (err, reply) ->
    response.render 'index.jade', entries: reply
