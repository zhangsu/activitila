express = require 'express'

facebook = require './facebook'

app = express()

app.get '/', (request, response) ->
  response.send('It works!')

app.get '/facebook/realtime', facebook.realtime.verify
app.post '/facebook/realtime', facebook.realtime.update

app.listen 8125

