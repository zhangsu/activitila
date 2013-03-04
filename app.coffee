express = require 'express'

controllers = require './controllers'

app = express()
app.use(express.static(__dirname + '/public'))
app.use(express.bodyParser())

app.get '/', controllers.root

app.get '/facebook/realtime', controllers.facebook.realtime.verify
app.post '/facebook/realtime', controllers.facebook.realtime.update

app.listen config = process.env.PORT or 8125
