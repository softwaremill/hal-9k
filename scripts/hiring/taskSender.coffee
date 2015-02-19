error = require './error'
trello = require './trello'
email = require './email'
bitbucket = require './bitbucket'

module.exports.sendTask = (query, robot, msg) ->
  nameAndLogin = extractNameAndBitbucketLogin(query)

  unless nameAndLogin?
    error(msg)("nie umiem wyciągnąć nazwy kandydata i loginu na Bitbucket z \"#{query}\"")

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
      repositoryName = extractRepositoryName(card.name)
      if repositoryName?
        bitbucket.createRepositoryAndGrantAccess(repositoryName, nameAndLogin.login, robot, sendEmail(emailAddress, card), onError)
      else
        error(msg)("nie umiem utworzyć nazwy repozytorium na podstawie \"#{card.name}\"")
    else
      error(msg)("nie znalazłem adresu e-mail w \"#{card.name}\"")

  trello.findCard(nameAndLogin.name, robot, processCard, error(msg))

extractNameAndBitbucketLogin = (query) ->
  matches = query.match(/(.*)\/(.*)/)
  if matches? and matches.length is 3
    name: matches[1]
    login: matches[2]

extractRepositoryName = (s) ->
  matches = s.match(/(.*)#.*#/)
  if matches? and matches[1].length > 0
    matches[1].trim().toLowerCase()
      .replace(/\s+/, '_')
      .replace('ą', 'a')
      .replace('ć', 'c')
      .replace('ę', 'e')
      .replace('ł', 'l')
      .replace('ń', 'n')
      .replace('ó', 'o')
      .replace('ś', 's')
      .replace('ż', 'z')
      .replace('ź', 'z')