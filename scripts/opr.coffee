store = require("./twjanusz/messagesMemory")
users = require './common/users'

GENERAL_ROOM_NAME = "ogolne"

MAX_COUNT_ALLOWED = 100
TIMESPAN_IN_MINUTES = 15

module.exports = (robot) ->
  robot.hear /.*/, (res) ->
    user = res.message.user
    if res.message.room is GENERAL_ROOM_NAME
      store.add(user)
      timespanSummary = store.countInTimespan(user, TIMESPAN_IN_MINUTES * 60)
      if timespanSummary.count >= MAX_COUNT_ALLOWED
        messagesRealTimespan = (new Date()).getTime() - timespanSummary.firstTimestamp
        messagesRealMinutes = Math.ceil(messagesRealTimespan / 1000 / 60)
        console.log("First message to now: #{messagesRealMinutes}")

        store.clearForUser(user)

        oprText = res.random opr
        res.reply("Napisanie ostatnich #{timespanSummary.count} wiadomości zajęło Ci zaledwie #{messagesRealMinutes} minut. #{oprText}")

  robot.respond /debugTajnyWsp (.*)/i, (res) ->
#   Works only in private messages to @janusz
    if (res.message.room == res.message.user.name)
      user = users.getUser(robot, res.match[1])
      repl = store.countInTimespan(user, TIMESPAN_IN_MINUTES * 60)
      res.reply("user: #{user.name}, count: #{repl.count}, timestamp: #{repl.firstTimestamp}")

opr = [
  "Zajmij się zwiększaniem PKB!"
  "Do roboty!"
  "Przestań w końcu trollować i zrób coś konstruktywnego."
  "Ogarnij się!"
  "Zajmij się czymś pożytecznym!"
  "Ile to by można kodu napisać!"
]
