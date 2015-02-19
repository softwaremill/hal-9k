URL = process.env.HUBOT_GRAMMAR_STATS_APP_URL
TOKEN = process.env.HUBOT_GRAMMAR_STATS_APP_AUTH_TOKEN

post = (endpoint, data, robot, successCallback, errorCallback) ->
  httpRequest(prepareRequest(endpoint, robot).post(JSON.stringify(data)), successCallback, errorCallback)

put = (endpoint, data, robot, successCallback, errorCallback) ->
  httpRequest(prepareRequest(endpoint, robot).put(JSON.stringify(data)), successCallback, errorCallback)

httpRequest = (f, successCallback, errorCallback) ->
  f (err, res, body) ->
    if err?
      errorCallback(err, res.statusCode)
    else
      successCallback(body)

prepareRequest = (endpoint, robot) ->
  robot.http("#{URL}#{endpoint}")
  .header('Content-Type', 'application/json')
  .header('Auth-token', TOKEN)

module.exports =
  post: post
  put: put
