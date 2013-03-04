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
Parse a `status` type data and return the parsed story string.
###
parseStatus = (data) ->
  return data.story if not data.story_tags

  pivot = 0
  result = ''
  # Process any tags for which we are interested.
  for offset, tags of data.story_tags
    # Currently not handling multiple tags at the same offset.
    continue if tags.length != 1

    tag = tags[0]
    if tag.type == 'user'
      [offset, length] = [parseInt(tag.offset), parseInt(tag.length)]
      result += data.story.substring(pivot, offset) +
          "<a href='http://facebook.com/" + tag.id + "'>" + tag.name + "</a>"
      pivot = offset + length

  # Return with the rest of the original string.
  result + data.story.substring(pivot)

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
            parsedStory = parseStatus(data)
            cache.add parsedStory, updatedTime

      callback()
  ]
