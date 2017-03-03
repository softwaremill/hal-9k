backend = require('./scalaTimesBackend')

module.exports.getCategories = (robot, onSuccess, onError) ->
  backend.get("/api/categories", robot, onSuccess, onError)

module.exports.addLink = (categoryId,link,robot, onSuccess, onError) ->
  data = {
    url : link
  }
  backend.post("/api/categories/#{categoryId}",data ,robot, onSuccess, onError)
