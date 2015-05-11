# Description:
#   To add and show kudos
#
# Commands:
#   hubot kudos show <username> - pokazuje kudosy danego usera
#

users = require './common/users'
kudos = require './kudos/kudosDao'

displayKudos = (robot, res, kudos) ->
  allUsers = users.getAllUsers(robot)
  userIdToNick = {}

  for user in allUsers
    userIdToNick[user.id] = user.name

  kudosAsString = for kudo in JSON.parse(kudos)
    "Od #{userIdToNick[kudo.kudoer]}: #{kudo.description}\n"

  res.reply(kudosAsString.join(''))


module.exports = (robot) ->
  robot.respond /kudos show @?(.*)/i, (res) ->
    kudosUser = res.match[1]

    user = users.getUser(robot, kudosUser)
    if (user == undefined)
      res.reply "Nie znam żadnego #{kudosUser}."
    else
      successHandler = (successBody) ->
        displayKudos(robot, res, successBody)

      errorHandler = (err, errCode) ->
        robot.logger.error "Error getting kudos from the backend. Error: #{error}"
        res.reply("Error #{errCode}")

      kudos.getKudos(robot, user.id, successHandler, errorHandler)


  robot.respond /kudos add @?(\w*) (.*)/i, (res) ->
    kudosReceiver = res.match[1]
    kudosDesc = res.match[2]

    user = users.getUser(robot, kudosReceiver)
    if (user == undefined)
      res.reply "Nie znam żadnego #{kudosReceiver}."
    else
      kudos.addKudos(robot, res, user.id, kudosDesc)
