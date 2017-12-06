# Description:
#   Zapisuje albo zwraca czwarte pytanie
#
# Commands:
#   hubot dodaj czwarte - zapisuje czwarte pytanie w kolejce. e.g. janusz dodaj czwarte Jakie opony na zimę?
#   hubot add 4te - zapisuje czwarte pytanie w kolejce
#   hubot dodaj czwarte - zapisuje czwarte pytanie w kolejce
#   hubot jakie czwarte - zwraca czwarte pytanie na dzisiaj
#   hubot daj czwarte - zwraca czwarte pytanie na dzisiaj
#   hubot dej 4te - zwraca czwarte pytanie na dzisiaj

fourthQuestion = require './fourth_question/FourthQuestionDao'

module.exports = (robot) ->
  add4thQ = (res) ->
    _4thQuestion = res.match[1]

    successHandler = (successBody) ->
      console.log("Response : #{successBody}")
      jsonBody = JSON.parse(successBody)
      res.reply(jsonBody.message)

    errorHandler =
      (err, errCode) -> res.reply("Error #{errCode}")

    res.reply("Przyjąłem...")
    fourthQuestion.add(robot, successHandler, errorHandler, res.message.user.name, _4thQuestion)


  get4thQ = (res) ->

    successHandler = (successBody) ->
      console.log("Response : #{successBody}")
      jsonBody = JSON.parse(successBody)
      res.reply("Czwarte pytanie na dzisiaj: #{jsonBody.message}")

    errorHandler =
      (err, errCode) -> res.reply("Error #{errCode}")

    res.reply("Szukam, szukam :)")
    fourthQuestion.get(robot, successHandler, errorHandler)

  robot.respond /4te add (.*)/i, add4thQ
  robot.respond /add 4te (.*)/i, add4thQ
  robot.respond /czwarte add (.*)/i, add4thQ
  robot.respond /add czwarte (.*)/i, add4thQ
  robot.respond /4te dodaj (.*)/i, add4thQ
  robot.respond /dodaj 4te (.*)/i, add4thQ
  robot.respond /czwarte dodaj (.*)/i, add4thQ
  robot.respond /dodaj czwarte (.*)/i, add4thQ

  robot.respond /daj 4te/i, get4thQ
  robot.respond /daj czwarte/i, get4thQ
  robot.respond /dej 4te/i, get4thQ
  robot.respond /dej czwarte/i, get4thQ
  robot.respond /jakie czwarte/i, get4thQ
  robot.respond /jakie 4te/i, get4thQ
