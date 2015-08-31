error = require './error'
trello = require './trello'
email = require './email'

module.exports.sendOnHoldMessage = (query, robot, msg) ->
  nameAndFirstName = extractNameAndWelcomeName(query)

  unless nameAndFirstName?
    return error(msg)("Nie umiem wyciągnąć nazwy kandydata i imienia do szablonu z \"#{query}\"")

  onSuccess = (address) ->
    -> msg.reply("Wysłałem maila 'onhold' do #{address}")

  onError = (err) ->
    error(msg)("Nie udało się wysłać maila (#{err})")

  sendEmail = (address, name) ->
    email.sendOnHoldMessage(address, name, onSuccess(address), onError)

  sendOnHoldMessage = (card) ->
    unless trello.isNew
      return error(msg)('On Hold message wysyłam tylko do nowych kartek')

    emailAddress = trello.extractEmailAddress(card)
    if emailAddress?
      sendEmail(emailAddress, nameAndFirstName.firstName)
    else
      error(msg)("Nie znalazłem adresu e-mail w \"#{card.name}\"")

  trello.findCard(nameAndFirstName.name, robot, sendOnHoldMessage, error(msg))

extractNameAndWelcomeName = (query) ->
  matches = query.match(/(.*)\s*\|\s*(.*)/)
  if matches? and matches.length is 3
    name: matches[1].trim()
    firstName: matches[2].trim()