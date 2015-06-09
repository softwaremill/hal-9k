error = require './error'
trello = require './trello'
backend = require '../common/backend'

module.exports.create = (query, robot, msg) ->
  name = query

  unless name?
    return error(msg)("Nie umiem wyciągnąć nazwy kandydata z \"#{query}\"")

  createWikiPage = (card) ->
    unless trello.isPreScreening(card) || trello.isGotSurvey(card) || trello.isTaskInProgress(card)
      return error(msg)('Stronę na kiwi tworzę tylko dla osób w statusie "Dostał ankietę", "Pre-screening" lub "Robi zadanie"')

    emailAddress = trello.extractEmailAddress(card)
    candidateName = trello.extractFullName(card)

    onSuccess = (data) ->
      -> msg.reply("Strona na kiwi stworzona - #{data.message}")

    onError = (err) ->
      error(msg)("Nie udało się stworzyć strony na kiwi (#{err})")

    extractUrlsAndCallBackend = (data) ->
      urls = []
      for attachment in data
        urls.push(attachment.url)

      if candidateName.indexOf('no fluff') >=0
        return error(msg)('Znalazłem "no fluff" zamiast imienia i nazwiska kandydata. Popraw karteczkę w Trello.')
      if emailAddress?
        data = {
          fullName: candidateName
          email: emailAddress
          attachments: urls
        }
        backend.put('/hiring/wiki-page', data, robot, onSuccess, onError)
      else
        error(msg)("Nie znalazłem adresu e-mail w \"#{card.name}\"")

    trello.getCardAttachmentUrls(robot, card, extractUrlsAndCallBackend, onError)

  trello.findCard(name, robot, createWikiPage, error(msg))
