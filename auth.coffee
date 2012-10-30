cheerio = require 'cheerio'
request = require 'request'
querystring = require 'querystring'

credentials = require './credentials'

fieldKey =
  email: 'email'
  pass: 'pass'

defaultHeaders =
  'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.4 ' +
                '(KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4'

facebookOAuthUrl = 'https://www.facebook.com/dialog/oauth?' +
  querystring.stringify(
    client_id:    credentials.facebook.clientId
    redirect_uri: 'https://arcane-depths-1190.herokuapp.com'
    scope:        'read_stream'
  )

# Convert hidden fields in Cheerio form object to a dict.
dictFromHiddenFormInput = (form) ->
  dict = {}

  form.find('input[type=hidden]').each ->
    dict[this.attr('name')] = this.attr('value')

  dict

# Try to login if the form is present (otherwise we have the session cookie).
tryLogin = ($) ->
  loginForm = $('#login_form')

  return unless loginForm.length > 0

  action = loginForm.attr('action')
  loginParams = dictFromHiddenFormInput(loginForm)
  loginParams[fieldKey.email] = credentials.facebook.email
  loginParams[fieldKey.pass] = credentials.facebook.pass

  request.post {
    url: action
    headers: defaultHeaders
    form: loginParams
    followAllRedirects: true
  }, (error, response, body) ->
    console.log body


exports.authenticate = ->
  request {
    url: facebookOAuthUrl
    headers: defaultHeaders
  }, (error, response, body) ->
    $ = cheerio.load(body)
    tryLogin($)
