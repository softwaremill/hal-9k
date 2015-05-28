error = require './error'
trello = require './trello'
backend = require '../common/backend'

module.exports.create = (query, robot, msg) ->
  name = query

  unless name?
    return error(msg)("nie umiem wyciągnąć nazwy kandydata z \"#{query}\"")

  trello.findCard(name, robot, createWikiPage(card), error(msg))

  onSuccess = (name) ->
    -> msg.reply("Strona na kiwi wiki dla #{name} stworzona")

  onError = (err) ->
    error(msg)("Nie udało się stworzyć strony na kiwi (#{err})")

  createWikiPage = (card) ->
    unless trello.isPreScreening(card) || trello.isGotSurvey(card) || trello.isTaskInProgress(card)
      return error(msg)('Stronę na kiwi tworzę tylko dla osób w statusie "Dostał ankietę", "Pre-screening" lub "Robi zadanie"')

    emailAddress = trello.extractEmailAddress(card)
    candidateName = trello.extractFullName(card)
    if candidateName.contains('no fluff')
      return error(msg)('Znalazłem "no fluff" zamiast imienia i nazwiska kandydata. Popraw karteczkę w Trello.')
    if emailAddress?
      data = {
        fullName: candidateName
        email: emailAddress
      }
      backend.put('/rest/hiring/wiki-page', data, robot, onSuccess(candidateName), onError)
    else
      error(msg)("Nie znalazłem adresu e-mail w \"#{card.name}\"")

  trello.findCard(name, robot, createWikiPage, error(msg))

extractNameFromQuery = (query) ->
  matches = query.match(/(.*)\s*\|\s*(.*)/)
  if matches? and matches.length is 3
    name: matches[1].trim()
    login: matches[2].trim()