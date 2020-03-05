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
#   hubot to jakie dziś czwarte - zwraca czwarte pytanie na dzisiaj
#   hubot jakie dziś czwarte - zwraca czwarte pytanie na dzisiaj
#   hubot poproszę o czwarte pytanie - zwraca czwarte pytanie na dzisiaj

fourthQuestion = require './fourth_question/FourthQuestionDao'

MONDAY = 1
WEDNESDAY = 3

module.exports = (robot) ->
  add4thQ = (res) ->
    _4thQuestion = res.match[1]

    successHandler = (successBody) ->
      robot.logger.debug("Response : #{successBody}")
      jsonBody = JSON.parse(successBody)
      res.reply(jsonBody.message)

    errorHandler =
      (err, errCode) -> res.reply("Error #{errCode}")

    res.reply("Przyjąłem, ładowacze klas ruszają do pracy...")
    fourthQuestion.add(robot, successHandler, errorHandler, res.message.user.name, _4thQuestion)


  get4thQ = (res) ->
    now = new Date()

    if now.getDay() == MONDAY
      res.reply 'Hej, dzisiaj poniedziałek, pytanie standardowe jak Ci minął weekend?'
    else if now.getDay() == WEDNESDAY
      res.reply 'Dzisiaj środa, nie ma pytania, kontemplujemy ciszę ;-)'
    else
      successHandler = (successBody) ->
        robot.logger.info("Response : #{successBody}")
        jsonBody = JSON.parse(successBody)
        res.reply("Czwarte pytanie na dzisiaj: #{jsonBody.message}")

      errorHandler =
        (err, errCode) -> res.reply("Error #{errCode}")

      res.reply("Proszę o cierpliwość, szukam ...")
      fourthQuestion.get(robot, successHandler, errorHandler)


  get5thQ = (res) ->

#{
#  "status": "IN_PROGRESS | COMPLETED",
#?  "winnerQuestionContent": "Jak leci?",
#?  "authorOfWinningQuestion": "@jacek",
#  "candidates": [
#    {
#      "id": "1",
#      "questionContent": "Czy miałeś palec?"
#    },
#    {
#      "id": "2",
#      "questionContent": "Czy usunąłeś czwarte?"
#    }
#  ]
#}

    now = new Date()

    if now.getDay() == MONDAY
      res.reply 'Hej, dzisiaj poniedziałek, pytanie standardowe jak Ci minął weekend?'
    else if now.getDay() == WEDNESDAY
      res.reply 'Dzisiaj środa, nie ma pytania, kontemplujemy ciszę ;-)'
    else
      successHandler = (successBody) ->
        robot.logger.info("Response : #{successBody}")
        jsonBody = JSON.parse(successBody)

        switch jsonBody.status
          when "IN_PROGRESS"
            votingText = "Kandydaci na 4te pytanie:\n"
            for candidate, i in jsonBody.candidates
              votingText += "#{i+1}. #{candidate.questionContent} (#{candidate.id})\n"

            votingText += "Zagłosuj przez dodanie :one: :two: :three: :four: lub :five:"
            res.reply(votingText)
          when "COMPLETED" then res.reply("Czwarte pytanie na dzisiaj: #{jsonBody.winnerQuestionContent} (autor: #{jsonBody.authorOfWinningQuestion})")
          else res.reply("Nieznany status głosowania :/ #{jsonBody.status}")

      errorHandler =
        (err, errCode) ->
          switch errCode
            when 404 then res.reply("Dzisiaj nie ma głosowania! Przynajmniej nie musisz wybierać mniejszego zła...")
            else res.reply("Error #{errCode}: #{err}")



      res.reply("Proszę o cierpliwość, szukam ...")
      fourthQuestion.get5(robot, successHandler, errorHandler)

  robot.respond /daj 5te/i, get5thQ





  
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
  robot.respond /to jakie dziś czwarte/i, get4thQ
  robot.respond /jakie dziś czwarte/i, get4thQ
  robot.respond /poproszę o czwarte pytanie/i, get4thQ

  robot.hear /^(januszu)? (.+)/i, (res) ->
    res.finish()

    robot.logger.info "Catching: #{res.match[2]}"

    message = res.message
    message.done = false
    message.text = message.text.replace(res.match[1], robot.name)

    robot.logger.info "Reroute message back to robot"
    robot.logger.info message
    robot.receive message
    return
