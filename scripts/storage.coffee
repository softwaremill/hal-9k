# Description:
#   Inspect the data in redis easily
#
# Commands:
#   hubot mózg help|pomoc|? - Pomoc do modułu mózg
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

  robot.respond /(help|pomoc|\?)/i, (msg) ->
    msg.send "pokaż mózg - wyświetla zawartość mózgu"
    msg.send "pokaż szkodników|użytkwoników - wyświetla wiedzę o użytkownikach"

