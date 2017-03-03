backend = require('./scalaTimesBackend')

module.exports.getCategories = (robot, onSuccess, onError) ->
  backend.get("/api/categories", robot, onSuccess, onError)

module.exports.addCategory = (categoryName,robot, onSuccess, onError) ->
  data = {
    name : categoryName
  }
  backend.post("/api/categories",data ,robot, onSuccess, onError)

module.exports.addLink = (categoryId,link,robot, onSuccess, onError) ->
  data = {
    url : link
  }
  backend.post("/api/categories/#{categoryId}",data ,robot, onSuccess, onError)
