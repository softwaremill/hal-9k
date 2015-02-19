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
#   hubot hr zadanie <name | bitbucket_login> - creates a Bitbucket repository with write access for <bitbucket_login>, sends notification to the email specified in the card matching <name>
#

error = require './hiring/error'
statusProvider = require './hiring/statusProvider'
surveySender = require './hiring/surveySender'
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
          when 'status' then statusProvider.getStatus(query, robot, msg)
          when 'ankieta' then surveySender.sendSurvey(query, robot, msg)
          when 'zadanie' then taskSender.sendTask(query, robot, msg)
      else if action is 'help'
        showUsage(robot, msg)
      else
        error(msg)("potrzebuję imienia i/lub nazwiska kandydata")

showUsage = (robot, msg) ->
  msg.reply("""
    hr help - wyświetla tę pomoc
    hr status <nazwa> - pokazuje status kandydata pasującego do <nazwa>
    hr ankieta <nazwa> - wysyła ankietę do kandydata pasującego do <nazwa>
    hr zadanie <nazwa | login_na_bitbucket> - tworzy repozytorium z dostępem dla <login_na_bitbucket>, wysyła informację do kandydata pasującego do <nazwa>
  """)