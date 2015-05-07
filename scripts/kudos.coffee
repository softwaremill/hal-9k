# Description:
#   To add and show kudos
#
# Commands:
#   hubot kudos show <username> - pokazuje kudosy danego usera
#

users = require './common/users'
kudos = require './kudos/kudosDao'

module.exports = (robot) ->
  robot.respond /kudos show (.*)/i, (res) ->
    kudosUser = res.match[1]

    user = users.getUser(robot, kudosUser)
    if (user == undefined)
      res.reply "Nie znam żadnego #{kudosUser}."
    else
      message = kudos.getKudos(user.id)
      res.reply(message)


  robot.respond /kudos add (\w*) (.*)/i, (res) ->
    kudosUser = res.match[1]
    kudosDesc = res.match[2]

    user = users.getUser(robot, kudosUser)
    if (user == undefined)
      res.reply "Nie znam żadnego #{kudosUser}."
    else
      message = kudos.addKudos(user.id, kudosDesc)
      res.reply(message)

