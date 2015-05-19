backend = require '../common/backend'

errorHandler = (messageResponse) ->
  (err, errCode) -> messageResponse.reply("Error #{errCode}")

#  onSuccess is a function: (successBody) -> do_smth
#  onError is a functin: (error, errorCode) -> do_smth
module.exports.getKudos = (robot, userId, onSuccess, onError) ->
  backend.get("/rest/kudos/#{userId}", robot, onSuccess, onError)

module.exports.addKudos = (robot, messageResponse, kudosReceiverId, description) ->
  data = {
    userName: kudosReceiverId,
    description: description,
    kudoer: messageResponse.message.user.id
  }

  successHandler = (successBody) ->
    jsonBody = JSON.parse(successBody)
    messageResponse.reply(if jsonBody.message? then jsonBody.message else successBody)

  backend.post("/rest/kudos", data, robot, successHandler, errorHandler(messageResponse))
