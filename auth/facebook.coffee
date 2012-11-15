cheerio = require 'cheerio'
request = require 'request'
querystring = require 'querystring'

credentials = require './credentials'


# The magical `code` retrieved after Facebook OAuth is done.
code = undefined

# The key names of the login POST form.
loginFormKey =
  email: 'email'
  pass: 'pass'

# Facebook OAuth API fails on improper user agent.
defaultHeaders =
  'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.4 ' +
                '(KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4'

oauthUrl = 'https://www.facebook.com/dialog/oauth?' +
  # The `state` field is not needed here because the app is not using any the
  # routes to check if Facebook gives us a `code` (i.e., not relying on
  # real browser requests with a `code` parameter), thus the app does not have
  # CSRF problems. It is retrieving `code` directly from the HTTP header using
  # the headless HTTP client.
  querystring.stringify(
    client_id:    credentials.facebook.clientId
    redirect_uri: 'http://0.0.0.0:8125/dummy'
    scope:        'read_stream'
  )

# Converts hidden fields in Cheerio form object to a dict.
dictFromHiddenFormInput = (form) ->
  dict = {}

  form.find('input[type=hidden]').each ->
    dict[this.attr('name')] = this.attr('value')

  dict

# Get the value of the `code` param in the returning GET request from the
# Facebook OAuth dialog page.
getCodeFromResponse = (response) ->
  querystring.parse(response.request.uri.query)['code']

# Automatically submits the login form.
login = (loginForm) ->
  action = loginForm.attr('action')
  loginParams = dictFromHiddenFormInput(loginForm)
  loginParams[loginFormKey.email] = credentials.facebook.email
  loginParams[loginFormKey.pass] = credentials.facebook.pass

  request.post {
    url: action
    headers: defaultHeaders
    form: loginParams
    followAllRedirects: true
  }, (error, response, body) ->
    code = getCodeFromResponse(response)

# Get a new `code` from Facebook.
refreshCode = ->
  request {
    url: oauthUrl
    headers: defaultHeaders
  }, (error, response, body) ->
    $ = cheerio.load(body)
    loginForm = $('#login_form')
    if loginForm.length > 0
      # Do login only if the login form is present.
      login(loginForm)
    else
      # Facebook session cookie is present so login form is skipped. Another
      # request with the `code` parameter is already being sent to
      # `redirect_uri`.
      code = getCodeFromResponse(response)

# Login to Facebook and get the `code` parameter.
exports.authenticate = ->
  refreshCode() unless code
