schedule = require 'node-schedule'

REMINDER_STORE_NAME = '__reminder_store'

class Reminder
  constructor: (@days, @roomName, @message) ->
    @scheduleDate = new Date()
    @scheduleDate.setDate @scheduleDate.getDate() + @days

    @id = Math.round @scheduleDate.getTime() * Math.random()

  isExpired: =>
    @scheduleDate.getTime() < new Date().getTime()

  schedule: (robot, done) =>
    robot.logger.info "Scheduling job at #{@scheduleDate}"

    schedule.scheduleJob @scheduleDate, =>
      robot.messageRoom @roomName, @message
      done()

  runNow: (robot) =>
    robot.messageRoom @roomName, @message

  remove: (robot) ->
    reminders = robot.brain.get REMINDER_STORE_NAME or []
    cleared = []
    for reminder in reminders?
      if reminder.id != @id
        cleared.push reminder

    robot.brain.set REMINDER_STORE_NAME, cleared

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
        reminder.schedule robot
        rebooted.push reminder

    robot.brain.set REMINDER_STORE_NAME, rebooted

module.exports.me = (robot, roomName, days, message) ->
  reminder = new Reminder days, roomName, message
  reminder.schedule robot, ->
    reminder.remove robot

  robot.messageRoom roomName, "Dodałem przypomnienie na dzień #{reminder.scheduleDate}!"

  reminders = robot.brain.get REMINDER_STORE_NAME or []
  reminders.push reminder
  robot.brain.set REMINDER_STORE_NAME, reminders