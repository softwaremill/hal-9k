_ = require 'lodash'
error = require './error'
trello = require './trello'
bitbucket = require './bitbucket'

module.exports.getStatus = (query, robot, msg) ->
  if query
    getStatusForCandidate(query, robot, msg)
  else
    getStatusForAllCandidates(robot, msg)

getStatusForCandidate = (query, robot, msg) ->
  replyWithStatusAndStats = (displayName, listName) ->
    (stats) ->
      message = if stats.numberOfCommits > 0 then "liczba commitów: #{stats.numberOfCommits}, ostatni commit #{stats.lastCommitOn}" else "brak commitów"
      msg.reply("#{displayName} ma status \"#{listName}\". Repozytorium utworzone #{stats.createdOn}, #{message}.")

  processCard = (card) ->
    displayName = extractDisplayName(card)

    if trello.isTaskInProgress(card)
      repositoryName = bitbucket.extractRepositoryName(card.name)
      bitbucket.getRepositoryStats(repositoryName, robot, replyWithStatusAndStats(displayName, card.listName), error(msg))
    else
      msg.reply("#{displayName} ma status \"#{card.listName}\"")

  trello.findCard(query, robot, processCard, error(msg))

getStatusForAllCandidates = (robot, msg) ->
  processCards = (cards) ->
    cardNamesByList = _(cards).groupBy('listName').mapValues((cards) -> _.map(cards, extractDisplayName)).value()

    status = _(cardNamesByList).mapValues((names) -> names.join(', ')).reduce((acc, names, listName) ->
      acc += "#{listName}: #{names}\n"
    , '')

    msg.reply "\n#{status}"

  trello.findAllCards(robot, processCards, error(msg))

extractDisplayName = (card) ->
  card.name.split(' ')[0..1].join(' ')