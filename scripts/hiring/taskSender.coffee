error = require './error'
trello = require './trello'
email = require './email'
bitbucket = require './bitbucket'
queryParser = require './queryParser'

module.exports.sendTask = (query, robot, msg) ->
  nameAndLogin = queryParser.extractNameAndWelcomeName(query)

  unless nameAndLogin?
    return error(msg)("nie umiem wyciągnąć nazwy kandydata i loginu na Bitbucket z \"#{query}\"")

  onSuccess = (address) ->
    -> msg.reply("Wysłałem zadanie do #{address}")

  onError = (err) ->
    error(msg)("nie udało się wysłać zadania (#{err})")

  moveCard = (address, card) ->
    -> trello.moveToTaskInProgress(card, robot, onSuccess(address), onError)

  sendEmail = (address, card) ->
    (repositoryUrl) -> email.sendTask(address, repositoryUrl, moveCard(address, card), onError)

  processCard = (card) ->
    unless trello.isPreScreening(card)
      return error(msg)('zadania wysyłam tylko do kartek z listy "Pre-screening call"')

    emailAddress = trello.extractEmailAddress(card)
    if emailAddress?
      repositoryName = bitbucket.extractRepositoryName(card.name)
      if repositoryName?
        bitbucket.createRepositoryAndGrantAccess(repositoryName, nameAndLogin.firstName, robot, sendEmail(emailAddress, card), onError)
      else
        error(msg)("nie umiem utworzyć nazwy repozytorium na podstawie \"#{card.name}\"")
    else
      error(msg)("nie znalazłem adresu e-mail w \"#{card.name}\"")

  trello.findCard(nameAndLogin.name, robot, processCard, error(msg))
