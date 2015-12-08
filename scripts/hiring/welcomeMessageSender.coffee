error = require './error'
trello = require './trello'
email = require './email'
queryParser = require './queryParser'

module.exports.sendWelcomeMessage = (query, robot, msg) ->
  nameAndFirstName = queryParser.extractNameAndWelcomeName(query)

  unless nameAndFirstName?
    return error(msg)("Nie umiem wyciągnąć nazwy kandydata i imienia do szablonu z \"#{query}\"")

  replyMessageSent = (text) ->
    () ->
      msg.reply(text)

  replyCommentFailed = (err) ->
    error(msg)("Wysłałem maila powiatalnego, ale nie udało się dodać komentarza do kartki (#{err})")

  commentMessageSent = (card, address) ->
    () ->
      text = "Wysłałem powitalnego maila do #{address}"
      trello.addCardComment(card, text, robot, replyMessageSent(text), replyCommentFailed)

  replyEmailFailed = (err) ->
    error(msg)("Nie udało się wysłać maila (#{err})")

  sendWelcomeEmail = (card) ->
    unless trello.isNew(card)
      return error(msg)('Welcome message wysyłam tylko do nowych kartek')

    address = trello.extractEmailAddress(card)
    if address?
      email.sendWelcomeMessage(address, nameAndFirstName.firstName, commentMessageSent(card, address), replyEmailFailed)
    else
      error(msg)("Nie znalazłem adresu e-mail w \"#{card.name}\"")

  trello.findCard(nameAndFirstName.name, robot, sendWelcomeEmail, error(msg))
