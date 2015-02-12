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
#   hubot hr zadanie <name> - sends task to the email specified in the card matching <name>
#

trello = require('./hiring/trello')(
  process.env.HUBOT_HIRING_BOARD_ID,
  process.env.HUBOT_TRELLO_KEY,
  process.env.HUBOT_TRELLO_TOKEN
)

email = require('./hiring/email')

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
          when 'zadanie' then sendTask(query, robot, msg)
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
    erorr(msg)("nie udało się wysłać ankiety (#{err})")

  send = (address) ->
    email.sendSurvey(address, onSuccess(address), onError)

  findEmail(query, robot, msg, send)

sendTask = (query, robot, msg) ->
  doSend = (address) ->
    msg.reply("[WIP] Wysłałem zadanie do #{address}")

  findEmail(query, robot, msg, doSend)

showUsage = (robot, msg) ->
  msg.reply("""
    hr help - wyświetla tę pomoc
    hr status <nazwa> - pokazuje status kandydata pasującego do <nazwa>
    hr ankieta <nazwa> - wysyła ankietę do kandydata pasującego do <nazwa>
    hr zadanie <nazwa> - wysyła zadanie do kandydata pasującego do <nazwa>
  """)

error = (msg) ->
  (err) ->
    msg.reply("Sorry, #{err}")

findEmail = (query, robot, msg, callback) ->
  extractEmail = (card) ->
    matches = card.name.match(/#(.*)#/)
    if matches?
      callback matches[1]
    else
      error(msg)("nie znalazłem adresu e-mail dla \"#{query}\"")

  trello.findCard(query, robot, extractEmail, error(msg))