express = require 'express'

controllers = require './controllers'
cache = require './logic/cache'

app = express()
app.use(express.static(__dirname + '/public'))
app.use(express.bodyParser())

app.get '/', (request, response) ->
  cache.get 0, 24, (err, reply) ->
    if reply.length > 0
      buffer = ''
      buffer += item + '<br>' for item in reply
      response.send(buffer)
    else
      response.send('Nothing to see here.')

app.get '/facebook/realtime', controllers.facebook.realtime.verify
app.post '/facebook/realtime', controllers.facebook.realtime.update

app.listen config = process.env.PORT or 8125
