async = require 'async'
redis = require 'redis'
url = require 'url'

db = null
# Setup Redis connection. REDISTOGO_URL will be present on Heroku.
if process.env.REDISTOGO_URL
  # Connect to Redis server on Heroku.
  components = url.parse(process.env.REDISTOGO_URL)
  db = redis.createClient(components.port, components.hostname)
  db.auth(components.auth.split(':')[1])
else
  # Connect to local Redis server.
  db = redis.createClient()

# The key of the Redis sorted set for this cache.
CACHE_KEY = 'feed'
###
The upper limit for the number of entries in the cache.
Heroku Redis To Go Nano (free plan) has a `maxmemory 5242880` configuration,
which is 5MB limit. By estimating the average size of a cache entry and save
1MB as a buffer zone, the cache size limit can be 4MB / average_entry_size.
###
CACHE_SIZE_LIMIT = (1024 * 1024 * 4) / 256

###
Get the last time the cache is updated. `callback` will be called and passed
with the actual timestamp.
###
exports.getLastUpdatedTime = (callback) ->
  # The largest score in the sorted set is essentially the last updated time.
  db.zrange CACHE_KEY, -1, -1, 'WITHSCORES', (err, reply) ->
    # The second element of the reply array is the score.
    callback(err, if reply.length > 0 then reply[1] else 0)

###
Add an new entry to the cache. `time` must be an integral timestamp.
###
exports.add = (string, time) ->
  cacheSize = null
  async.series [
    (callback) ->
      db.zcard CACHE_KEY, (err, reply) ->
        cacheSize = reply
        callback(err)
    ,
    (callback) ->
      if cacheSize >= CACHE_SIZE_LIMIT
        # Remove oldest cache entry as we are running out of free space.
        db.zremrangebyrank CACHE_KEY, 0, 0, (err, reply) ->
          callback(err)
      else
        callback()
  ]

  # No need to wait for the above operations as we have a 1MB buffer zone.
  db.zadd CACHE_KEY, time, string

###
Retrieve a range of items in the cache. `start` is the index of the newest item
to retrieve and `stop` is the index of the oldest item to retrieve.
###
exports.get = (start, stop, callback) ->
  db.zrevrange CACHE_KEY, start, stop, 'WITHSCORES', (err, reply) ->
    associationArray = []
    if not err
      for i in [0...reply.length] by 2
        associationArray.push [reply[i], reply[i + 1]]

    callback(err, associationArray)
