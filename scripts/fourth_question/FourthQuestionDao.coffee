backend = require '../common/backend'

module.exports.get = (robot, onSuccess, onError) ->
  backend.get "/rest/fourth-question", robot, onSuccess, onError

module.exports.add = (robot, onSuccess, onError, author, question) ->
  data = {
    question: question,
    author: "@" + author
  }

  backend.post("/rest/fourth-question", data, robot, onSuccess, onError)