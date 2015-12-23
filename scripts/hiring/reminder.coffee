schedule = require 'node-schedule'

REMINDER_STORE_NAME = '__reminder_store'

class Reminder
  constructor: (@days, @roomName, @message) ->
    @scheduleDate = new Date()
    @scheduleDate.setDate @scheduleDate.getDate() + @days

  isExpired: =>
    @scheduleDate.getTime() < new Date().getTime()

  run: (robot) =>
    schedule.scheduleJob @scheduleDate, =>
      robot.messageRoom @roomName, @message

  runNow: (robot) =>
    robot.messageRoom @roomName, @message

# it's a bug in Hubot https://github.com/github/hubot/issues/880
firstTime = true

module.exports.init = (robot) ->
  robot.brain.on 'loaded', ->
    if not firstTime
      return

    firstTime = false

    robot.logger.info "Reading reminders from #{REMINDER_STORE_NAME}"

    reminders = robot.brain.get REMINDER_STORE_NAME or []
    rebooted = []

    robot.logger.info "Existing reminders:\n#{reminders}"

    for reminder in reminders?
      if reminder.isExpired
        reminder.runNow robot
      else
        reminder.run robot
        rebooted.push reminder

    robot.brain.set REMINDER_STORE_NAME, rebooted

module.exports.me = (robot, roomName, days, message) ->
  reminder = new Reminder days, roomName, message
  reminder.run robot

  robot.messageRoom roomName, "Dodałem przypomnienie na dzień #{reminder.scheduleDate}!"

  reminders = robot.brain.get REMINDER_STORE_NAME or []
  reminders.push reminder
  robot.brain.set REMINDER_STORE_NAME, reminders
