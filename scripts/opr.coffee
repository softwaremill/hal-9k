store = require("./twjanusz/messagesMemory")

GENERAL_ROOM_NAME = "ogolne"

MAX_COUNT_ALLOWED = 100
TIMESPAN_IN_MINUTES = 15

store = require("./twjanusz/messagesMemory")


module.exports = (robot) ->
  robot.hear /.*/, (res) ->
    user = res.message.user
    if res.message.room is GENERAL_ROOM_NAME
      store.add(user)
      timespanSummary = store.countInTimespan(user, TIMESPAN_IN_MINUTES * 60)
      if timespanSummary.count > MAX_COUNT_ALLOWED
        messagesRealTimespan = (new Date()).getTime() - timespanSummary.firstTimestamp
        messagesRealMinutes = Math.ceil(messagesRealTimespan / 1000 / 60)
        console.log("First message to now: #{messagesRealMinutes}")

        store.clearForUser(user)

        oprText = res.random opr
        res.reply("#{user.name} w ciągu ostatnich #{messagesRealMinutes} minut wyprodukowałeś #{timespanSummary.count} wiadomości. #{oprText}")


opr = [
  "Zajmij się zwiększaniem PKB!"
  "Do roboty!"
  "Przestań w końcu trollować i zrób coś konstruktywnego."
  "Ogarnij się!"
  "Zajmij się czymś pożytecznym!"
  "Ile to by można kodu napisać!"
]
