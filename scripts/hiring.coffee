# Description:
#   Hiring helpers
#
# Configuration:
#   HUBOT_TRELLO_KEY, HUBOT_TRELLO_TOKEN, HUBOT_HIRING_ROOM_NAME, HUBOT_HIRING_BOARD_ID
#
# Commands:
#   hubot hr help - shows HR commands
#

error = require './hiring/error'
statusProvider = require './hiring/statusProvider'
surveySender = require './hiring/surveySender'
welcomeMessageSender = require './hiring/welcomeMessageSender'
onHoldMessageSender = require './hiring/onHoldMessageSender'
taskSender = require './hiring/taskSender'
wikiCreator = require './hiring/wikiCreator'

HIRING_ROOM_NAME = process.env.HUBOT_HIRING_ROOM_NAME

module.exports = (robot) ->
  robot.respond /hr (help|status|welcome|onhold|ankieta|wiki|kiwi|zadanie|review)\s?((.*\s*)+)/i, (msg) ->
    action = msg.match[1]
    if msg.message.room isnt HIRING_ROOM_NAME
      error(msg)("akcja \"hr #{action}\" działa tylko na kanale ##{HIRING_ROOM_NAME}")
    else
      query = msg.match[2]
      if action is 'help'
        showUsage msg
      else if action is 'status'
        statusProvider.getStatus(query, robot, msg)
      else if query
        switch action
          when 'ankieta' then surveySender.sendSurvey(query, robot, msg)
          when 'welcome' then welcomeMessageSender.sendWelcomeMessage(query, robot, msg)
          when 'onhold' then onHoldMessageSender.sendOnHoldMessage(query, robot, msg)
          when 'zadanie' then taskSender.sendTask(query, robot, msg)
          when 'wiki' then wikiCreator.create(query, robot, msg)
          when 'kiwi' then wikiCreator.create(query, robot, msg)
          when 'review' then msg.reply("review #{query}")
      else
        error(msg)("potrzebuję imienia i/lub nazwiska kandydata")

showUsage = (msg) ->
  msg.send """
    hr help - wyświetla tę pomoc
    hr status <nazwa> - pokazuje status kandydata pasującego do <nazwa>
    hr welcome <name | firstName> - wysyła powitalnego maila do kandudata <name> używając <firstName> w szablonie wiadomości
    hr onhold <name | firstName> - wysyła maila z info o wstrzymaniu rekrutacji do kandudata <name> używając <firstName> w szablonie wiadomości
    hr ankieta <nazwa | firstName>  - wysyła ankietę do kandydata pasującego do <nazwa> używając <firstName> w szablonie wiadomości
    hr wiki|kiwi <nazwa> - tworzy stronę na Kiwi o kandydacie pasującym do <nazwa>
    hr zadanie <nazwa | login_na_bitbucket> - tworzy repozytorium z dostępem dla <login_na_bitbucket>, wysyła informację do kandydata pasującego do <nazwa>
  """