backend = require '../common/backend'

#  onSuccess is a function: (successBody) -> do_smth
#  onError is a functin: (error, errorCode) -> do_smth
module.exports.getKudos = (robot, userId, onSuccess, onError) ->
  backend.get("/rest/kudos/#{userId}", robot, onSuccess, onError)

module.exports.addKudos = (robot, successHandler, errorHandler, kudoer, kudosReceiverId, description) ->
  data = {
    userName: kudosReceiverId,
    description: description,
    kudoer: kudoer
  }

  backend.post("/rest/kudos", data, robot, successHandler, errorHandler)

module.exports.addPlusOne = (robot, successHandler, errorHandler, kudoer, kudoId, description) ->
  data = {
    description: description,
    userName: kudoer
  }

  backend.post("/rest/kudos/#{kudoId}/plusOnes", data, robot, successHandler, errorHandler)

module.exports.addPlusOneByDesc = (robot, successHandler, errorHandler, kudosRewardedId, kudosGiverId, description) ->
  data = {
    description: description,
    kudosRewardedId: kudosRewardedId,
    kudosGiverId: kudosGiverId
  }

  backend.put("/rest/kudos/plus-one", data, robot, successHandler, errorHandler)
