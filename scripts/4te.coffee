# Description:
#   Genrates 4th question
#
# Commands:
#   hubot czwarte dodaj
#   hubot czwarte add
#   hubot 4te add
#   hubot 4te dodaj

czwarte = require './4te/4teDao'

module.exports = (robot) ->
  add4te = (res) ->
    _4teQuestion = res.match[1]

    successHandler = (successBody) ->
      jsonBody = JSON.parse(successBody)
      res.reply("Ok, 4te dodane. ID=#{jsonBody.id}")

    errorHandler =
      (err, errCode) -> res.reply("Error #{errCode}")

    czwarte.add4te(robot, successHandler, errorHandler, res.message.user.id, _4teQuestion)

  robot.respond /4te add (.*)/i, add4te
  robot.respond /czwarte add (.*)/i, add4te
  robot.respond /4te dodaj (.*)/i, add4te
  robot.respond /czwarte dodaj (.*)/i, add4te
  robot.respond /dodaj czwarte (.*)/i, add4te
  robot.respond /dodaj 4te (.*)/i, add4te
