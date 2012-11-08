express = require 'express'

auth = require './auth'

app = express()

app.get '/', (request, response) ->
  auth.facebook.authenticate()
  response.send('It works!')

app.listen 8125

