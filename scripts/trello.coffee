# Description:
#   Manage your Trello Board from Hubot!
#
# Dependencies:
#   "node-trello": "latest"
#
# Configuration:
#   HUBOT_TRELLO_KEY - Trello application key
#   HUBOT_TRELLO_TOKEN - Trello API token
#   HUBOT_TRELLO_BOARD - The ID of the Trello board you will be working with
#
# Commands:
#   hubot trello new "<list>" <name> - Create a new Trello card in the list
#   hubot trello list "<list>" - Show cards on list
#   hubot trello move <shortLink> "<list>" - Move a card to a different list
#
#
# Author:
#   jared barboza <jared.m.barboza@gmail.com>

board = {}
lists = {}

Trello = require 'node-trello'

trello = new Trello process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN

# verify that all the environment vars are available
ensureConfig = (out) ->
  out "Error: Trello app key is not specified" if not process.env.HUBOT_TRELLO_KEY
  out "Error: Trello token is not specified" if not process.env.HUBOT_TRELLO_TOKEN
  out "Error: Trello board ID is not specified" if not process.env.HUBOT_TRELLO_BOARD
  return false unless (process.env.HUBOT_TRELLO_KEY and process.env.HUBOT_TRELLO_TOKEN and process.env.HUBOT_TRELLO_BOARD)
  true

##############################
# API Methods
##############################

createCard = (msg, list_name, cardName) ->
  msg.reply "Spoko szefie, już dodaj kartkę!"
  ensureConfig msg.send
  id = lists[list_name.toLowerCase()].id
  trello.post "/1/cards", {name: cardName, idList: id}, (err, data) ->
    msg.reply "Nie mogę utworzyć kartki :(" if err
    msg.reply "Gotowe, kartka zrobioan, tu jest: #{data.url}" unless err

showCards = (msg, list_name) ->
  msg.reply "Czekaj, szukam kartek na #{list_name} ..."
  ensureConfig msg.send
  id = lists[list_name.toLowerCase()].id
  msg.send "Nie ma takiej listy #{list_name} :(" unless id
  if id
    trello.get "/1/lists/#{id}", {cards: "open"}, (err, data) ->
      msg.reply "Jakiś błąd przy listowaniu :(" if err
      msg.reply "Oto kartki z #{data.name}:" unless err and data.cards.length == 0
      msg.send "* [#{card.shortLink}] #{card.name} - #{card.shortUrl}" for card in data.cards unless err and data.cards.length == 0
      msg.reply "Nie ma żadnych kartek na #{data.name}" if data.cards.length == 0 and !err

moveCard = (msg, card_id, list_name) ->
  ensureConfig msg.send
  id = lists[list_name.toLowerCase()].id
  msg.reply "Nie ma takiej listy #{list_name}." unless id
  if id
    trello.put "/1/cards/#{card_id}/idList", {value: id}, (err, data) ->
      msg.reply "Nie dałem rady przesunąć tej kartki :(" if err
      msg.reply "Gotowe, kartka przesunięta do #{list_name}." unless err

module.exports = (robot) ->
  # fetch our board data when the script is loaded
  ensureConfig console.log
  trello.get "/1/boards/#{process.env.HUBOT_TRELLO_BOARD}", (err, data) ->
    board = data
    trello.get "/1/boards/#{process.env.HUBOT_TRELLO_BOARD}/lists", (err, data) ->
      for list in data
        lists[list.name.toLowerCase()] = list

  robot.respond /trello new ["'](.+)["']\s(.*)/i, (msg) ->
    ensureConfig msg.send
    card_name = msg.match[2]
    list_name = msg.match[1]

    if card_name.length == 0
      msg.reply "Hej, a gdzie nazwa kartki?!?"
      return

    if list_name.length == 0
      msg.reply "Hej, a gdzie nazwa listy?!?"
      return
    return unless ensureConfig()

    createCard msg, list_name, card_name

  robot.respond /trello list ["'](.+)["']/i, (msg) ->
    showCards msg, msg.match[1]

  robot.respond /trello move (\w+) ["'](.+)["']/i, (msg) ->
    moveCard msg, msg.match[1], msg.match[2]

  robot.respond /trello list lists/i, (msg) ->
    msg.reply "Oto wszystkie listy:"
    Object.keys(lists).forEach (key) ->
      msg.send " * " + key

  robot.respond /trello help/i, (msg) ->
    msg.send " *  trello new '<ListName>' <TaskName>"
    msg.send " *  trello list '<ListName>'"
    msg.send " *  shows * [<card.shortLink>] <card.name> - <card.shortUrl>"
    msg.send " *  trello move <card.shortlink> '<ListName>'"
    msg.send " *  trello list lists"
