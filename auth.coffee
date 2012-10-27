cheerio = require 'cheerio'
request = require 'request'
querystring = require 'querystring'

credentials = require './credentials'

facebookOAuthUrl = 'https://www.facebook.com/dialog/oauth?' +
  querystring.stringify {
    client_id:    credentials.facebook.clientId,
    redirect_uri: 'https://arcane-depths-1190.herokuapp.com',
    scope:        'read_stream'
  }

exports.loginToFacebook = ->
  request facebookOAuthUrl, (error, response, body) ->
    $ = cheerio.load(body)
    console.log $('#login_form')
