error = require './error'
trello = require './trello'
email = require './email'
queryParser = require './queryParser'
schedule = require 'node-schedule'

HIRING_ROOM_NAME = process.env.HUBOT_HIRING_ROOM_NAME

module.exports.sendSurvey = (query, robot, msg) ->
  nameAndFirstName = queryParser.extractNameAndWelcomeName(query)
  unless nameAndFirstName?
    return error(msg)("Nie umiem wyciągnąć nazwy kandydata i imienia do szablonu z \"#{query}\"")

  onSuccess = (address) ->
    -> msg.reply("Wysłałem ankietę do #{address}")

  onError = (err) ->
    error(msg)("nie udało się wysłać ankiety (#{err})")

  moveCard = (card, address) ->
    -> trello.moveToGotSurvey(card, robot, onSuccess(address), onError)

  processCard = (card) ->
    unless trello.isWelcomed(card)
      return error(msg)('ankiety wysyłam tylko do kartek z listy "Powitany(a)"')

    emailAddress = trello.extractEmailAddress(card)
    if emailAddress?
      email.sendSurvey(emailAddress, nameAndFirstName.firstName,  moveCard(card, emailAddress), onError)

      date = new Date
      date.setDate date.getDate + 3
      schedule.scheduleJob date, ->
        msg.messageRoom HIRING_ROOM_NAME, "@channel Sprawdźcie czy #{emailAddress} - #{nameAndFirstName.firstName} wypełnij już ankietę!"

      msg.send "Dodałem przypomnienie na dzień #{date} aby sprawdzić wynik ankiety"

    else
      error(msg)("nie znalazłem adresu e-mail dla \"#{nameAndFirstName.name}\"")

  trello.findCard(nameAndFirstName.name, robot, processCard, error(msg))