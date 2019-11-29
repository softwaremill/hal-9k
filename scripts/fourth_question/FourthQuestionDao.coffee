backend = require '../common/backend'

module.exports.get = (robot, onSuccess, onError) ->
  backend.get "/rest/fourth-question", robot, onSuccess, onError

module.exports.add = (robot, onSuccess, onError, author, question) ->
  data = {
    question: question,
    author: "@" + author
  }

  backend.post("/rest/fourth-question", data, robot, onSuccess, onError)


module.exports.get5 = (robot, onSuccess, onError) ->
  backend.get "/rest/fourth-question/v2", robot, onSuccess, onError

module.exports.add5 = (robot, onSuccess, onError, author, question) ->
  data = {
    question: question,
    author: "@" + author
  }

  backend.post("/rest/fourth-question/v2", data, robot, onSuccess, onError)