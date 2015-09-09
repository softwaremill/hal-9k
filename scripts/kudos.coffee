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
    "\nOd #{kudo.kudoer.name}: #{kudo.description} (id=#{kudo.id})"

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

  addPlusOne = (res) ->
    kudosId = res.match[1]
    kudosDesc = res.match[2]
    kudos.addPlusOne(robot, res, kudosId, kudosDesc)

  robot.respond /kudos \+1 @?([0-9]+)\s?((.*\s*)+)/i, addPlusOne

  robot.respond /kudos help/i, (res) ->
    kudosAppLogin = process.env.HUBOT_KUDOS_APP_LOGIN
    kudosAppPassword = process.env.HUBOT_KUDOS_APP_PASSWORD
    res.reply("""
      kudos help - wyświetla tę pomoc
      kudos show <nazwa> - pokazuje kudosy dla użytkownika <nazwa>
      kudos pokaż dla <nazwa> - j.w.
      kudos add <nazwa> <treść> - dodaje kudosa o treści <treść> dla użytkownika <nazwa>
      kudos dodaj dla <nazwa> <treść> - j.w.
      kudos +1 <id> <komentarz> - dodaje +1 do kudosa o id <id> z opcjonalnym komentarzem <komentarz>

      Kudosy są dostępne na stronie http://kudos.softwaremill.com
      Login: #{kudosAppLogin}
      Hasło: #{kudosAppPassword}
    """)
