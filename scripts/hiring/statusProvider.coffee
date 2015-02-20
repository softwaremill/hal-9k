error = require './error'
trello = require './trello'
bitbucket = require './bitbucket'

module.exports.getStatus = (query, robot, msg) ->
  replyWithStatusAndStats = (displayName, listName) ->
    (stats) ->
      message = if stats.numberOfCommits > 0 then "liczba commitów: #{stats.numberOfCommits}, ostatni commit #{stats.lastCommitOn}" else "brak commitów"
      msg.reply("#{displayName} ma status \"#{listName}\". Repozytorium utworzone #{stats.createdOn}, #{message}.")

  processCard = (card) ->
    displayName = extractDisplayName(card, query)

    if trello.isTaskInProgress(card)
      repositoryName = bitbucket.extractRepositoryName(card.name)
      bitbucket.getRepositoryStats(repositoryName, robot, replyWithStatusAndStats(displayName, card.listName), error(msg))
    else
      msg.reply("#{displayName} ma status \"#{card.listName}\"")

  trello.findCard(query, robot, processCard, error(msg))

extractDisplayName = (card, query) ->
  matches = card.name.match(/(.*)#.*#/)
  if matches? and matches[1].length > 0
    matches[1].trim()
  else
    query