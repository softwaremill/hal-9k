error = require './error'
trello = require './trello'

module.exports.getStatus = (query, robot, msg) ->
  replyWithListName = (json) ->
    msg.reply("#{query} ma status \"#{json.name}\"")

  trello.findListByCardQuery(query, robot, replyWithListName, error(msg))