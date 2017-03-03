URL = process.env.HUBOT_SCALA_TIMES_APP_URL

module.exports.post = (endpoint, data, robot, successCallback, errorCallback) ->
  p = prepareRequest(endpoint, robot)
  httpRequest(p.post(JSON.stringify(data)), successCallback, errorCallback)

module.exports.put = (endpoint, data, robot, successCallback, errorCallback) ->
  httpRequest(prepareRequest(endpoint, robot).put(JSON.stringify(data)), successCallback, errorCallback)

module.exports.get = (endpoint, robot, successCallback, errorCallback) ->
  httpRequest(prepareRequest(endpoint, robot).get(), successCallback, errorCallback)

httpRequest = (f, successCallback, errorCallback) ->
  f (err, res, body) ->
    if err? or res.statusCode != 200
      errorCallback(err ? res.statusCode)
    else
      successCallback(body,res.statusCode)

prepareRequest = (endpoint, robot) ->
  unless URL?
    robot.logger.warning "HUBOT_SCALA_TIMES_APP_URL env variable not set. Won't be able to send data to scalatimes backend"
  robot.http("#{URL}#{endpoint}")
  .header('Content-Type', 'application/json')