error = require './error'
trello = require './trello'
email = require './email'
queryParser = require './queryParser'
remind = require './reminder'

HIRING_ROOM_NAME = process.env.HUBOT_HIRING_ROOM_NAME

module.exports.sendSurvey = (query, robot, msg) ->
  nameAndFirstName = queryParser.extractNameAndWelcomeName(query)
  unless nameAndFirstName?
    return error(msg)("Nie umiem wyciągnąć nazwy kandydata i imienia do szablonu z \"#{query}\"")

  onSuccess = (address) ->
    -> msg.send "Wysłałem ankietę do #{address}"

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

      remind.me robot,
        HIRING_ROOM_NAME,
        1,
        "@channel Sprawdźcie czy #{emailAddress} wypełnij już ankietę!"

    else
      error(msg)("nie znalazłem adresu e-mail dla \"#{nameAndFirstName.name}\"")

  trello.findCard(nameAndFirstName.name, robot, processCard, error(msg))