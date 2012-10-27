express = require 'express'
auth = require './auth'

app = express()

app.get '/', (request, response) ->
  auth.loginToFacebook()
  response.send 'It works!'

app.listen 8124

