error = require './error'
trello = require './trello'
email = require './email'
queryParser = require './queryParser'

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
    unless trello.isNew(card)
      return error(msg)('ankiety wysyłam tylko do kartek z listy "Nowe"')

    emailAddress = trello.extractEmailAddress(card)
    if emailAddress?
      email.sendSurvey(emailAddress, nameAndFirstName.firstName,  moveCard(card, emailAddress), onError)
    else
      error(msg)("nie znalazłem adresu e-mail dla \"#{query}\"")

  trello.findCard(query, robot, processCard, error(msg))