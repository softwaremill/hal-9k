backend = require '../common/backend'

module.exports.addPoints = (robot, userId, activityCode, onSuccess, onError) ->
  requestBody = {
    userId
    activityCode
  }
  backend.post "/kw/points", requestBody, robot, onSuccess, onError

module.exports.addCustomPoints = (robot, userId, points, description, onSuccess, onError) ->
  requestBody = {
    userId
    description
    points
  }
  backend.post "/kw/points/custom", requestBody, robot, onSuccess, onError

module.exports.showPoints = (robot, userName, onSuccess, onError) ->
  backend.get "/kw/points/#{userName}", robot, onSuccess, onError

module.exports.showAllPoints = (robot, onSuccess, onError) ->
  backend.get "/kw/points", robot, onSuccess, onError

module.exports.listActivities = (robot, onSuccess, onError) ->
  backend.get "/kw/activities", robot, onSuccess, onError

module.exports.listRanks = (robot, onSuccess, onError) ->
  backend.get "/kw/ranks", robot, onSuccess, onError

module.exports.withdrawPoints = (robot, userId, pointsId, onSuccess, onError) ->
  requestBody = {
    userId
  }
  backend.delete "/kw/points/#{pointsId}", requestBody, robot, onSuccess, onError