redis = require 'redis'

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

exports.db = db
