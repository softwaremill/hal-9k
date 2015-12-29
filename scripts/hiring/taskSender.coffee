trello = require './trello'
email = require './email'
bitbucket = require './bitbucket'
queryParser = require './queryParser'

module.exports.sendTask = (query, robot, msg) ->
  nameAndLogin = queryParser.extractNameAndWelcomeName(query)

  unless nameAndLogin?
    return msg.reply "Nie umiem wyciągnąć nazwy kandydata i loginu na Bitbucket z \"#{query}\""

  onSuccess = (address) ->
    msg.reply "Wysłałem zadanie do #{address}"

  onError = (err) ->
    robot.logger.error err
    msg.reply "Nie udało się wysłać zadania :("

  moveCard = (address, card) ->
    -> trello.moveToTaskInProgress(card, robot, onSuccess(address), onError)

  sendEmail = (address, card) ->
    (repositoryUrl) -> email.sendTask(address, repositoryUrl, moveCard(address, card), onError)

  processCard = (card) ->
    unless trello.isPreScreening(card)
      return msg.reply 'Zadania wysyłam tylko do kartek z listy "Pre-screening call"'

    emailAddress = trello.extractEmailAddress(card)
    if emailAddress?
      repositoryName = bitbucket.extractRepositoryName(card.name)

      robot.logger.info "Extracted repository name [#{repositoryName}]"

      if repositoryName?
        bitbucket.createRepositoryAndGrantAccess(repositoryName, nameAndLogin.firstName, robot, sendEmail(emailAddress, card), onError)
      else
        msg.reply "Nie umiem utworzyć nazwy repozytorium na podstawie \"#{card.name}\""
    else
      msg.reply "Nie znalazłem adresu e-mail w \"#{card.name}\""

  onSendError = (err) ->
    msg.reply err

  trello.findCard(nameAndLogin.name, robot, processCard, onSendError)
