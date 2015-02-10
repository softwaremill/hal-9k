# Description:
#   Hiring helpers
#
# Configuration:
#   TRELLO_KEY, TRELLO_TOKEN, HIRING_ROOM_NAME
#
# Commands:
#   hubot hr help - shows HR commands
#   hubot hr status <name> - shows status of the Trello card matching <name>
#   hubot hr ankieta <name> - sends survey to the email specified in the card matching <name>
#   hubot hr zadanie <name> - sends task to the email specified in the card matching <name>
#

_ = require('lodash');

TRELLO_KEY = process.env.HUBOT_TRELLO_KEY
TRELLO_TOKEN = process.env.HUBOT_TRELLO_TOKEN
HIRING_ROOM_NAME = process.env.HUBOT_HIRING_ROOM_NAME
HIRING_BOARD_ID = process.env.HUBOT_HIRING_BOARD_ID

module.exports = (robot) ->
  robot.respond /hr (help|status|ankieta|zadanie)\s?(.*)/i, (msg) ->
    action = msg.match[1]
    if msg.message.room isnt HIRING_ROOM_NAME
      msg.reply("Akcja \"#{action}\" działa tylko na kanale ##{HIRING_ROOM_NAME}")
    else
      name = msg.match[2]
      if name
        switch action
          when 'status' then showStatus(name, robot, msg)
          when 'ankieta' then sendSurvey(name, robot, msg)
          when 'zadanie' then sendTask(name, robot, msg)
      else if action is 'help'
        showUsage(robot, msg)
      else
        msg.reply("Sorry, potrzebuję imienia i/lub nazwiska kandydata")

showStatus = (name, robot, msg) ->
  replyWithListName = (json) ->
    msg.reply("#{name} ma status \"#{json.name}\"")

  extractStatus = (card) ->
    queryTrello("https://api.trello.com/1/lists/#{card.idList}", {}, robot, replyWithListName)

  findCard(name, robot, msg, extractStatus)

sendSurvey = (name, robot, msg) ->
  doSend = (email) ->
    msg.reply("[WIP] Wysłałem ankietę do #{email}")

  findEmail(name, robot, msg, doSend)

sendTask = (name, robot, msg) ->
  doSend = (email) ->
    msg.reply("[WIP] Wysłałem zadanie do #{email}")

  findEmail(name, robot, msg, doSend)

showUsage = (robot, msg) ->
  msg.reply("""
    hr help - wyświetla tę pomoc
    hr status <nazwa> - pokazuje status kandydata pasującego do <nazwa>
    hr ankieta <nazwa> - wysyła ankietę do kandydata pasującego do <nazwa>
    hr zadanie <nazwa> - wysyła zadanie do kandydata pasującego do <nazwa>
  """)

findCard = (name, robot, msg, successCallback) ->
  searchParams =
    modelTypes: 'cards'
    idBoards: HIRING_BOARD_ID
    query: name

  error = (err) ->
    msg.reply("Sorry, #{err}")

  extractCard = (json) ->
    switch json.cards.length
      when 0 then error("nie znalazłem kartki dla \"#{name}\"")
      when 1 then successCallback(json.cards[0])
      else error("znalazłem więcej niż jedną kartkę dla \"#{name}\"")

  queryTrello('https://api.trello.com/1/search', searchParams, robot, extractCard, error)

findEmail = (name, robot, msg, callback) ->
  extractEmail = (card) ->
    email = card.name.match(/#(.*)#/)
    if email
      callback(email[1])
    else
      msg.reply("Nie znalazłem adresu e-mail dla \"#{name}\"")

  findCard(name, robot, msg, extractEmail)

queryTrello = (url, queryParams, robot, successCallback, errorCallback) ->
  trelloKeyAndToken =
    key: TRELLO_KEY
    token: TRELLO_TOKEN

  robot.http(url)
  .query(_.assign(trelloKeyAndToken, queryParams))
  .get() (err, res, body) ->
    if err
      errorCallback(err)
    else
      successCallback(JSON.parse(body))