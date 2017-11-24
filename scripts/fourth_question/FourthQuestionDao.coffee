URL = process.env.FOURTH_QUESTION_LAMBDA_URL

post = (endpoint, data, robot, successCallback, errorCallback) ->
  httpRequest(prepareRequest(endpoint, robot).post(JSON.stringify(data)), successCallback, errorCallback)

get = (endpoint, robot, successCallback, errorCallback) ->
  httpRequest(prepareRequest(endpoint, robot).get(), successCallback, errorCallback)

httpRequest = (f, successCallback, errorCallback) ->
  f (err, res, body) ->
    if err?
      errorCallback(err, res.statusCode)
    else
      successCallback(body)

prepareRequest = (endpoint, robot) ->
  robot.http(endpoint)
    .header('Content-Type', 'application/json')

#  onSuccess is a function: (successBody) -> do_smth
#  onError is a function: (error, errorCode) -> do_smth
module.exports.get = (robot, onSuccess, onError) ->
  get("#{URL}", robot, onSuccess, onError)

module.exports.add = (robot, successHandler, errorHandler, author, question) ->
  data = {
    question: question,
    author: author
  }

  post(URL, data, robot, successHandler, errorHandler)
