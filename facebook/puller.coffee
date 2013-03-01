async = require 'async'
querystring = require 'querystring'
request = require 'request'
url = require 'url'

credentials = require './credentials'
cache = require '../cache'

apiUrl = (fields) ->
  "https://graph.facebook.com/#{credentials.basic.uid}?" +
    querystring.stringify {
      fields: 'feed'
      access_token: credentials.basic.accessToken
    }

###
Pull and cache feed from Facebook.
###
pullFeed = ->
  console.log 'Updating feed cache...'

  lastUpdatedTime = null

  async.parallel [
    (callback) ->
      cache.db.get "facebook:updated_time", (err, reply) ->
        lastUpdatedTime = new Date(reply)
        callback(null)
  ],
  ->
    console.log lastUpdatedTime
    request apiUrl('feed'), (error, response, body) ->
      feedData = JSON.parse(body).feed.data
      for data in feedData
        updatedTime = new Date(data.updated_time)
        if (updatedTime > lastUpdatedTime)
          console.log 'Time to cache a new feed entry!'

    cache.db.set "facebook:updated_time", new Date()

###
Pull data from Facebook based on realtime update payload.
###
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
