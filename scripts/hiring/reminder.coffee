schedule = require 'node-schedule'

REMINDER_STORE_NAME = '__reminder_store'

class Reminder
  constructor: (@days, @roomName, @message) ->
    @scheduleDate = new Date().getDate + @days

  isExpired: =>
    @date.getTime < new Date().getTime

  run: (robot) =>
    schedule.scheduleJob @scheduleDate, =>
      robot.messageRoom @roomName, @message

  runNow: (robot) =>
    robot.messageRoom @roomName, @message

module.exports = (robot) ->
  robot.brain.on 'loaded', ->
    reminders = robot.brain.get REMINDER_STORE_NAME
    rebooted = []

    for reminder in reminders
      if reminder.isExpired
        reminder.runNow robot
      else
        reminder.run robot
        rebooted.push reminder

    robot.brain.set REMINDER_STORE_NAME, rebooted

module.exports.me = (robot, roomName, days, message) ->
  reminder = new Reminder days, roomName, message
  reminder.run robot

  robot.messageRoom roomName, "Dodałem przypomnienie na dzień #{date}!"

  reminders = robot.brain.get REMINDER_STORE_NAME
  reminders.push reminder
  robot.brain.set REMINDER_STORE_NAME, reminders
