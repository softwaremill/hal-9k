backend = require '../common/backend'

#  onSuccess is a function: (successBody) -> do_smth
#  onError is a functin: (error, errorCode) -> do_smth
module.exports.getKudos = (robot, userId, onSuccess, onError) ->
  backend.get("/rest/kudos/#{userId}", robot, onSuccess, onError)

module.exports.addKudos = (robot, successHandler, errorHandler, kudoer, kudosReceiverId, description, messageId) ->
  data = {
    userName: kudosReceiverId,
    description: description,
    kudoer: kudoer
    messageId: messageId
  }

  backend.post("/rest/kudos", data, robot, successHandler, errorHandler)

module.exports.addPlusOne = (robot, successHandler, errorHandler, kudoer, kudoId, description) ->
  data = {
    description: description,
    userName: kudoer
  }

  backend.post("/rest/kudos/#{kudoId}/plusOnes", data, robot, successHandler, errorHandler)

module.exports.addPlusOneByMessageId = (robot, successHandler, errorHandler, kudosRewardedId, messageId, description) ->
  data = {
    description: description,
    kudosRewardedId: kudosRewardedId,
    messageId: messageId
  }

  backend.put("/rest/kudos/plus-one", data, robot, successHandler, errorHandler)
