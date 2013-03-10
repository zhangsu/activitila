cache = require '../logic/cache'

exports.facebook = require './facebook'

exports.root = (request, response) ->
  MAX_LENGTH = 25
  offset = parseInt(request.query['offset'])
  length = parseInt(request.query['length'])

  offset = 0 if isNaN(offset) or offset < 0
  if isNaN(length) or length > MAX_LENGTH
    length = MAX_LENGTH
  else if length < 1
    length = 1

  cache.get offset, offset + length - 1, (err, reply) ->
    response.format
      'json': ->
        response.json reply
      ,
      'html': ->
        response.render 'index.jade', entries: reply
