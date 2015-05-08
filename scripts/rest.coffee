users = require './common/users'

module.exports = (robot) ->
  robot.router.get '/users', (req, res) ->
    res.send users.getAllUsers(robot)