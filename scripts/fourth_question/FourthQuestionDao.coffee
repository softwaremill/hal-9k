backend = require '../common/backend'

module.exports.get = (robot, onSuccess, onError) ->
  backend.get "/rest/fourth-question", robot, onSuccess, onError

module.exports.add = (robot, onSuccess, onError, author, question) ->
  data = {
    question: question,
    author: "@" + author
  }

  backend.post("/rest/fourth-question", data, robot, onSuccess, onError)

module.exports.vote = (robot, votingUser, votedQuestion, electionDate) ->
  data = {
    votedQuestion: votedQuestion
    electionDate: electionDate
    votingUser: votingUser
  }

  onSuccess = (body, response) ->
    robot.logger.debug("User #{votingUser} voted for question #{votedQuestion} (#{electionDate}). Status: #{response.statusCode}. Body: #{body}")

  onError = (err, errCode) ->
    robot.logger.error("Error voting on question #{votedQuestion} by user #{votingUser}: (#{errCode}) #{err}")

  backend.post("/rest/fourth-question/voted", data, robot, onSuccess, onError)
