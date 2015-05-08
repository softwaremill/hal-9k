backend = require '../common/backend'

errorHandler = (messageResponse) ->
  (err, errCode) -> messageResponse.reply("Error #{errCode}")

module.exports.getKudos = (robot, messageResponse, userId) ->
  successHandler = (successBody) ->
    messageResponse.reply(successBody)

  backend.get("/kudos/#{userId}", robot, successHandler, errorHandler(messageResponse))

module.exports.addKudos = (robot, messageResponse, kudosReceiverId, description) ->
  data = {
    userName: kudosReceiverId,
    description: description,
    kudoer: messageResponse.message.user.id
  }

  successHandler = (successBody) ->
    jsonBody = JSON.parse(successBody)
    messageResponse.reply(if jsonBody.message? then jsonBody.message else successBody)

  backend.post("/kudos", data, robot, successHandler, errorHandler(messageResponse))
