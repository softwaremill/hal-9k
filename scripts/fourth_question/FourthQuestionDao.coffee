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
  robot.logger.info("Adding 5th question: #{data}")
  data = {
    question: question,
    author: "@" + author
  }

  backend.post("/rest/fourth-question/v2", data, robot, onSuccess, onError)

module.exports.vote = (robot, votingUser, votedQuestionId) ->
  data = {
    votedQuestionId: votedQuestionId
    votingUser: votingUser
  }

  onSuccess = (successBody) ->
    robot.logger.debug("User #{votingUser} voted successfully for question #{votedQuestionId}")

  onError = (err, errCode) ->
    robot.logger.error("Error voting on question #{votedQuestionId} by user #{votingUser}: (#{errCode}) #{err}")

  backend.post("rest/fourth-question/v2/voted", data, robot, onSuccess, onError)