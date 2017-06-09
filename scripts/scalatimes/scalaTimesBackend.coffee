KJUR = require 'jsrsasign'

URL = process.env.HUBOT_SCALA_TIMES_APP_URL
JWT_SECRET = process.env.HUBOT_SCALA_TIMES_APP_JWT_SECRET

module.exports.post = (endpoint, data, robot, successCallback, errorCallback) ->
  httpRequest(prepareRequest(endpoint, robot).post(JSON.stringify(data)), successCallback, errorCallback)

module.exports.put = (endpoint, data, robot, successCallback, errorCallback) ->
  httpRequest(prepareRequest(endpoint, robot).put(JSON.stringify(data)), successCallback, errorCallback)

module.exports.get = (endpoint, robot, successCallback, errorCallback) ->
  httpRequest(prepareRequest(endpoint, robot).get(), successCallback, errorCallback)

httpRequest = (f, successCallback, errorCallback) ->
  f (err, res, body) ->
    if err? or res.statusCode != 200
      errorCallback(err ? ("Status code: " + res.statusCode + "; response body: " + body))
    else
      successCallback(body,res.statusCode)

prepareRequest = (endpoint, robot) ->
  unless URL?
    robot.logger.warning "HUBOT_SCALA_TIMES_APP_URL env variable not set. Won't be able to send data to scalatimes backend"
  unless JWT_SECRET?
    robot.logger.warning "HUBOT_SCALA_TIMES_APP_JWT_SECRET env variable not set. Won't be able to send data to backend"
  robot.http("#{URL}#{endpoint}")
  .header('Content-Type', 'application/json')
  .header('Authorization', "Bearer #{generateToken()}")


generateToken = () ->
  alg = 'HS256'
  header = {alg: alg, typ: 'JWT'}
  payload =
  iss : "scalatimes"
  iat : KJUR.jws.IntDate.get('now')
  sHeader = JSON.stringify(header)
  sPayload = JSON.stringify(payload)
  KJUR.jws.JWS.sign(alg, sHeader, sPayload, JWT_SECRET)
