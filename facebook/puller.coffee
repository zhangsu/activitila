credentials = require './credentials'

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
          console.log 'time to update feed cache!'
