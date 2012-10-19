express = require 'express'

app = express()

app.get '/', (request, response) ->
  response.send 'It works!'

app.listen 8124

