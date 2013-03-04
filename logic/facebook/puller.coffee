async = require 'async'
querystring = require 'querystring'
request = require 'request'
url = require 'url'

credentials = require './credentials'
cache = require '../cache'

apiUrl = (fields) ->
  "https://graph.facebook.com/#{credentials.basic.uid}?" +
    querystring.stringify {
      fields: fields
      access_token: credentials.basic.accessToken
    }

###
Pull and cache feed from Facebook.
###
exports.pullFeed = ->
  console.log 'Updating feed cache...'

  # Last updated timestamp.
  lastUpdatedTime = null

  async.series [
    (callback) ->
      cache.getLastUpdatedTime (err, time) ->
        lastUpdatedTime = time
        callback(err)
    ,
    (callback) ->
      # Call Facebook Graph API to fetch the feed data. Assuming all fields
      # exists or else Facebook API is broken.
      request apiUrl('feed'), (err, response, body) ->
        return if err
        for data in JSON.parse(body).feed.data
          updatedTime = new Date(data.updated_time).valueOf()
          continue if updatedTime < lastUpdatedTime

          if data.type == 'status'
            cache.add data.story, updatedTime if data.story

      callback()
  ]
