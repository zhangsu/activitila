request = require 'request'
querystring = require 'querystring'
credentials = require './credentials'

url = (fields) ->
  "https://graph.facebook.com/#{credentials.basic.uid}?" +
    querystring.stringify {
      fields: 'feed'
      access_token: credentials.basic.accessToken
    }

pullFeed = ->
  console.log 'Updating feed cache...'
  request url('feed'), (error, response, body) ->
    feedData = JSON.parse(body).feed.data
    for data in feedData
      console.log JSON.stringify(data, null, 4)

exports.pull = (payload) ->
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
          pullFeed()
