error = require './error'
trello = require './trello'
email = require './email'
queryParser = require './queryParser'
remind = require './reminder'

HIRING_ROOM_NAME = process.env.HUBOT_HIRING_ROOM_NAME

module.exports.sendSurvey = (query, robot, msg) ->

  matches = msg.match[2].match /^(dev|grafik)(.*|.*)$/i

  if not matches
    msg.reply "Hej, nie mogę wykryć typu ankiety!"
    return

  suffix = matches[1]?.trim()
  name = matches[2]?.trim()

  robot.logger.info "Sending survey to #{name} of type #{suffix}"

  nameAndFirstName = queryParser.extractNameAndWelcomeName name
  unless nameAndFirstName?
    return msg.reply "Nie umiem wyciągnąć nazwy kandydata i imienia do szablonu z \"#{name}\""

  onSuccess = (address) ->
    -> msg.send "Wysłałem ankietę do #{address}"

  onError = (err) ->
    msg.reply "nie udało się wysłać ankiety: #{err}"

  moveCard = (card, address) ->
    -> trello.moveToGotSurvey(card, robot, onSuccess(address), onError)

  processCard = (card) ->
    unless trello.isWelcomed(card)
      return msg.reply 'ankiety wysyłam tylko do kartek z listy "Powitany(a)"'

    emailAddress = trello.extractEmailAddress(card)
    if emailAddress?
      email.sendSurvey(emailAddress, suffix, nameAndFirstName.firstName,  moveCard(card, emailAddress), onError)

      remind.me robot,
        HIRING_ROOM_NAME,
        3,
        "@channel Sprawdźcie czy #{nameAndFirstName.firstName} (#{emailAddress}) wypełnij już ankietę!"

    else
      error(msg)("nie znalazłem adresu e-mail dla \"#{nameAndFirstName.name}\"")

  trello.findCard(nameAndFirstName.name, robot, processCard, error(msg))