express = require 'express'

auth = require './auth'

app = express()

app.get '/', (request, response) ->
  auth.facebook.authenticate()
  response.send('It works!')

app.get '/dummy', (request, response) ->
  response.send(200)

app.listen 8125

