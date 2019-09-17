backend = require '../common/backend'
#  onSuccess is a function: (successBody) -> do_smth
#  onError is a function: (error, errorCode) -> do_smth
module.exports.get = (robot, onSuccess, onError) ->
  backend.get "/rest/fourth-question", robot, onSuccess, onError