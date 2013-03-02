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

  # Last updated timestamp.
  lastUpdatedTime = null

  async.parallel [
    (callback) ->
      cache.getLastUpdatedTime (err, time) ->
        lastUpdatedTime = time
        callback(err)
  ],
  ->
    # Call Facebook Graph API to fetch the feed data.
    request apiUrl('feed'), (err, response, body) ->
      return if err

      feedData = JSON.parse(body).feed.data
      for data in feedData
        updatedTime = new Date(data.updated_time).valueOf()
        continue if updatedTime < lastUpdatedTime

        if data.type == 'status'
          cache.add data.story, updatedTime

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
