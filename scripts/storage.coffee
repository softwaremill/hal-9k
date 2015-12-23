# Description:
#   Inspect the data in redis easily
#
# Commands:
#   hubot pokaż help|pomoc|? - Pomoc do modułu mózg
#

Util = require "util"

module.exports = (robot) ->
  robot.respond /pokaż mózg$/i, (msg) ->
    output = Util.inspect(robot.brain.data, false, 4)
    msg.send output

  robot.respond /pokaż (szkodników|użytkowników)$/i, (msg) ->
    response = ""

    for own key, user of robot.brain.data.users
      response += "#{user.id} #{user.name}"
      response += " <#{user.email_address}>" if user.email_address
      response += "\n"

    msg.send response

  robot.respond /mózg$/i, (msg) ->
    msg.send "Mam :)"

  robot.respond /pokaż (help|pomoc|\?)$/i, (msg) ->
    msg.send 'pokaż mózg - wyświetla zawartość mózgu'
    msg.send 'pokaż szkodników|użytkowników - wyświetla wiedzę o użytkownikach'
    msg.send 'pokaż co masz w <nazwa> - wyświetla zawartość <nazwa>'
    msg send 'usuń wszystko z <nazwa> - usuwa całą zawartość <nazwa>'

  robot.respond /pokaż co masz w (.*)$/, (msg) ->
    store = robot.brain.get msg.match[1]
    msg.send "To jest zawartość #{msg.match[1]}:"
    msg.send JSON.stringify store

  robot.respond /usuń wszystko z (.*)$/, (msg) ->
    msg.send "Usuwam całą zawartość #{msg.match[1]}"
    robot.brain.set msg.match[1]
