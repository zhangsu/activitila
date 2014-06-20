express = require 'express'

controllers = require './controllers'

publicDirname = __dirname + '/public'

app = express()
app.use express.static(publicDirname)
app.use express.json()
app.use express.urlencoded()
app.use require('cookie-parser')()
app.use require('connect-assets')(buildDir: publicDirname)

css.root = '/stylesheets'
js.root = '/javascripts'

app.get '/', controllers.index

app.get '/facebook/realtime', controllers.facebook.realtime.verify
app.post '/facebook/realtime', controllers.facebook.realtime.update

app.listen config = process.env.PORT or 8125
