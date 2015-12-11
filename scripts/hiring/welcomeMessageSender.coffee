error = require './error'
trello = require './trello'
email = require './email'
queryParser = require './queryParser'
schedule = require 'node-schedule'

HIRING_ROOM_NAME = process.env.HUBOT_HIRING_ROOM_NAME

module.exports.sendWelcomeMessage = (query, robot, msg) ->
  nameAndFirstName = queryParser.extractNameAndWelcomeName(query)

  unless nameAndFirstName?
    return error(msg)("Nie umiem wyciągnąć nazwy kandydata i imienia do szablonu z \"#{query}\"")

  replyMessageSent = (address) ->
    () ->
      msg.reply("Wysłałem powitalnego maila do #{address}")

  replyMoveFailed = (err) ->
    error(msg)("Wysłałem maila powiatalnego, ale nie udało się przenieść kartki do powitanych (#{err})")

  moveToWelcomed = (card, address) ->
    () ->
      trello.moveToWelcomed(card, robot, replyMessageSent(address), replyMoveFailed)

  replyEmailFailed = (err) ->
    error(msg)("Nie udało się wysłać maila (#{err})")

  sendWelcomeEmail = (card) ->
    unless trello.isNew(card)
      return error(msg)('Welcome message wysyłam tylko do nowych kartek')

    address = trello.extractEmailAddress(card)
    if address?
      email.sendWelcomeMessage(address, nameAndFirstName.firstName, moveToWelcomed(card, address), replyEmailFailed)

      date = new Date
      date.setDate date.getDate + 3
      schedule.scheduleJob date, ->
        msg.messageRoom HIRING_ROOM_NAME, "@channel Sprawdźcie czy #{address} - #{nameAndFirstName.firstName} wypełnij już ankietę!"

      msg.send "Dodałem przypomnienie na dzień #{date} aby sprawdzić wynik ankiety"

    else
      error(msg)("Nie znalazłem adresu e-mail w \"#{card.name}\"")

  trello.findCard(nameAndFirstName.name, robot, sendWelcomeEmail, error(msg))
