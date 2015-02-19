error = require './error'
trello = require './trello'
bitbucket = require './bitbucket'

module.exports.getStatus = (query, robot, msg) ->
  replyWithStatusAndStats = (displayName, list) ->
    (stats) ->
      message = if stats.numberOfCommits > 0 then "liczba commitów: #{stats.numberOfCommits}, ostatni commit #{stats.lastCommitOn}" else "brak commitów"
      msg.reply("#{displayName} ma status \"#{list.name}\". Repozytorium utworzone #{stats.createdOn}, #{message}.")

  processCardAndList = (card) ->
    (list) ->
      displayName = extractDisplayName(card, query)

      if trello.isTaskInProgress(card)
        repositoryName = bitbucket.extractRepositoryName(card.name)
        bitbucket.getRepositoryStats(repositoryName, robot, replyWithStatusAndStats(displayName, list), error(msg))
      else
        msg.reply("#{displayName} ma status \"#{list.name}\"")

  findList = (card) ->
    trello.findListById(card.idList, robot, processCardAndList(card), error(msg))

  trello.findCard(query, robot, findList, error(msg))

extractDisplayName = (card, query) ->
  matches = card.name.match(/(.*)#.*#/)
  if matches? and matches[1].length > 0
    matches[1].trim()
  else
    query