redis = require 'redis'
request = require 'request'
url = require 'url'
querystring = require 'querystring'
credentials = require './credentials'

if process.env.REDISTOGO_URL
  components = url.parse(process.env.REDISTOGO_URL)
  db = redis.createClient(components.port, components.hostname)
  db.auth(components.auth.split(':')[1])
else
  db = redis.createClient()

apiUrl = (fields) ->
  "https://graph.facebook.com/#{credentials.basic.uid}?" +
    querystring.stringify {
      fields: 'feed'
      access_token: credentials.basic.accessToken
    }

pullFeed = ->
  console.log 'Updating feed cache...'
  last_updated_time = null

  db.get "facebook:updated_time", (err, reply) ->
    last_updated_time = new Date(reply)

  request apiUrl('feed'), (error, response, body) ->
    feedData = JSON.parse(body).feed.data
    for data in feedData
      updated_time = new Date(data.updated_time)
      if (updated_time > last_updated_time)
        console.log 'Time to cache a new feed entry!'

  db.set "facebook:updated_time", new Date()

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
