users = require './common/users'

SECRET = process.env.REST_API_SECRET

module.exports = (robot) ->
  unless SECRET?
    robot.logger.warning "REST_API_SECRET env variable not set. Won't be able to serve users data"

  robot.router.get '/users', (req, res) ->
    secret = req.header("Authorization")

    unless SECRET?
      res.send "SECRET is not set. Can't send users data."
    else
      if secret == SECRET
        res.send users.getAllUsers(robot)
      else
        res.send "Unauthorized"
