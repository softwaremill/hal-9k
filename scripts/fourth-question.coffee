# Description:
#   Genrates 4th question
#
# Commands:
#   hubot czwarte dodaj
#   hubot czwarte add
#   hubot 4te add
#   hubot 4te dodaj

fourthQuestion = require './fourth_question/FourthQuestionDao'

module.exports = (robot) ->
  add4thQ = (res) ->
    _4thQuestion = res.match[1]

    successHandler = (successBody) ->
      console.log("Response : #{successBody}")
      jsonBody = JSON.parse(successBody)
      res.reply("Ok, czwarte pytanie dodane. ID=#{jsonBody.id}")

    errorHandler =
      (err, errCode) -> res.reply("Error #{errCode}")

    fourthQuestion.add(robot, successHandler, errorHandler, res.message.user.id, _4thQuestion)

  robot.respond /4te add (.*)/i, add4thQ
  robot.respond /czwarte add (.*)/i, add4thQ
  robot.respond /4te dodaj (.*)/i, add4thQ
  robot.respond /czwarte dodaj (.*)/i, add4thQ
  robot.respond /dodaj czwarte (.*)/i, add4thQ
  robot.respond /dodaj 4te (.*)/i, add4thQ
