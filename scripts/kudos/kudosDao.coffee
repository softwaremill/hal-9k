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

module.exports.addPlusOneByMessageId = (robot, successHandler, errorHandler, kudosGiverId, messageId) ->
  data = {
    kudosGiverId: kudosGiverId,
    messageId: messageId
  }

  backend.put("/rest/kudos/plus-one", data, robot, successHandler, errorHandler)

module.exports.isKudos = (robot, successHandler, errorHandler, messageId) ->
  backend.get("/rest/kudos/is-kudos/#{messageId}", robot, successHandler, errorHandler)
