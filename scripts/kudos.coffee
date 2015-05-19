# Description:
#   To add and show kudos
#
# Commands:
#   hubot kudos show <username> - pokazuje kudosy danego usera
#

users = require './common/users'
kudos = require './kudos/kudosDao'

displayKudos = (robot, res, kudos) ->
  kudosAsString = for kudo in JSON.parse(kudos)
    "Od #{kudo.kudoer.name}: #{kudo.description}\n"

  res.reply(kudosAsString.join(''))


module.exports = (robot) ->
  showKudos = (res) ->
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

  robot.respond /kudos show @?(.*)/i, showKudos
  robot.respond /kudos pokaż dla @?(.*)/i, showKudos

  addKudos = (res) ->
    kudosReceiver = res.match[1]
    kudosDesc = res.match[2]

    user = users.getUser(robot, kudosReceiver)
    if (user == undefined)
      res.reply "Nie znam żadnego #{kudosReceiver}."
    else
      kudos.addKudos(robot, res, user.id, kudosDesc)

  robot.respond /kudos add @?(\w*) (.*)/i, addKudos
  robot.respond /kudos dodaj dla @?(\w*) (.*)/i, addKudos

  robot.respond /kudos help/i, (res) ->
    res.reply("""
      kudos help - wyświetla tę pomoc
      kudos show <nazwa> - pokazuje kudosy dla użytkownika <nazwa>
      kudos pokaż dla <nazwa> - j.w.
      kudos add <nazwa> <treść> - dodaje kudosa o treści <treść> dla użytkownika <nazwa>
      kudos dodaj dla <nazwa> <treść> - j.w.
    """)
