# Description:
#   Hiring helpers
#
# Configuration:
#   HUBOT_TRELLO_KEY, HUBOT_TRELLO_TOKEN, HUBOT_HIRING_ROOM_NAME, HUBOT_HIRING_BOARD_ID
#
# Commands:
#   hubot hr help - shows HR commands
#   hubot hr status <name> - shows status of the Trello card matching <name>
#   hubot hr ankieta <name> - sends survey to the email specified in the card matching <name>
#   hubot hr zadanie <name>/<bitbucket login> - creates a Bitbucket repository with write access for <bitbucket login>, sends notification to the email specified in the card matching <name>
#

trello = require('./hiring/trello')
email = require('./hiring/email')
taskSender = require './hiring/taskSender'

HIRING_ROOM_NAME = process.env.HUBOT_HIRING_ROOM_NAME

module.exports = (robot) ->
  robot.respond /hr (help|status|ankieta|zadanie)\s?(.*)/i, (msg) ->
    action = msg.match[1]
    if msg.message.room isnt HIRING_ROOM_NAME
      error(msg)("akcja \"hr #{action}\" działa tylko na kanale ##{HIRING_ROOM_NAME}")
    else
      query = msg.match[2]
      if query
        switch action
          when 'status' then showStatus(query, robot, msg)
          when 'ankieta' then sendSurvey(query, robot, msg)
          when 'zadanie' then taskSender.sendTask(query, robot, msg)
      else if action is 'help'
        showUsage(robot, msg)
      else
        error(msg)("potrzebuję imienia i/lub nazwiska kandydata")

showStatus = (query, robot, msg) ->
  replyWithListName = (json) ->
    msg.reply("#{query} ma status \"#{json.name}\"")

  trello.findListByCardQuery(query, robot, replyWithListName, error(msg))

sendSurvey = (query, robot, msg) ->
  onSuccess = (address) ->
    -> msg.reply("Wysłałem ankietę do #{address}")

  onError = (err) ->
    error(msg)("nie udało się wysłać ankiety (#{err})")

  moveCard = (card, address) ->
    -> trello.moveToGotSurvey(card, robot, onSuccess(address), onError)

  processCard = (card) ->
    unless trello.isNew(card)
      return error(msg)('ankiety wysyłam tylko do kartek z listy "Nowe"')

    emailAddress = extractEmailAddress(card)
    if emailAddress?
      email.sendSurvey(emailAddress, moveCard(card, emailAddress), onError)
    else
      error(msg)("nie znalazłem adresu e-mail dla \"#{query}\"")

  trello.findCard(query, robot, processCard, error(msg))

showUsage = (robot, msg) ->
  msg.reply("""
    hr help - wyświetla tę pomoc
    hr status <nazwa> - pokazuje status kandydata pasującego do <nazwa>
    hr ankieta <nazwa> - wysyła ankietę do kandydata pasującego do <nazwa>
    hr zadanie <nazwa>/<login na Bitbucket> - tworzy repozytorium z dostępem dla <login na Bitbucket>, wysyła informację do kandydata pasującego do <nazwa>
  """)

error = (msg) ->
  (err) ->
    msg.reply("Sorry, #{err}")

extractEmailAddress = (card) ->
  matches = card.name.match(/#(.*)#/)
  matches[1] if matches?