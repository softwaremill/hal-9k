# Description:
#   To add and show kudos
#
# Commands:
#   hubot kudos show <username> - pokazuje kudosy danego usera
#

users = require './common/users'
kudos = require './kudos/kudosDao'


module.exports = (robot) ->
  kudos.checkSecret(robot)

  robot.respond /kudos show (.*)/i, (res) ->
    kudosUser = res.match[1]

    user = users.getUser(robot, kudosUser)
    if (user == undefined)
      res.reply "Nie znam żadnego #{kudosUser}."
    else
      kudos.getKudos(robot, res, user.id)


  robot.respond /kudos add @?(\w*) (.*)/i, (res) ->
    kudosReceiver = res.match[1]
    kudosDesc = res.match[2]

    user = users.getUser(robot, kudosReceiver)
    if (user == undefined)
      res.reply "Nie znam żadnego #{kudosReceiver}."
    else
      kudos.addKudos(robot, res, user.id, kudosDesc)
