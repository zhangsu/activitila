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
  db.zadd CACHE_KEY, time, string
