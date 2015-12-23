schedule = require 'node-schedule'

REMINDER_STORE_NAME = '__reminder_store'

class Reminder
  constructor: (@days, @roomName, @message) ->
    @scheduleDate = new Date()
    @scheduleDate.setDate @scheduleDate.getDate() + @days

    @id = Math.round @scheduleDate.getTime() * Math.random()

  isExpired: =>
    @scheduleDate.getTime() <= new Date().getTime()

class ReminderRoller

  constructor: (reminder) ->
    @id = reminder.id
    @roomName = reminder.roomName
    @message = reminder.messge
    @scheduleDate = reminder.scheduleDate

  schedule: (robot, done) =>
    robot.logger.info "Scheduling job at #{@scheduleDate}"

    schedule.scheduleJob @scheduleDate, =>
      @run robot, done

  run: (robot, done) =>
    robot.messageRoom @roomName, @message
    done()

  remove: (robot) ->
    reminders = robot.brain.get(REMINDER_STORE_NAME) || []
    cleared = []

    for reminder in reminders
      if reminder?.id != @id
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

    reminders = robot.brain.get(REMINDER_STORE_NAME) || []
    rebooted = []

    robot.logger.info "Existing reminders:"
    robot.logger.info JSON.stringify reminders

    for reminder in reminders
      if reminder
        if reminder.isExpired
          robot.logger.info "Reminder #{reminder.id} expired, run it now!"

          roller = new ReminderRoller reminder
          roller.run robot, ->

        else
          robot.logger.info "Re-scheduling reminder #{reminder.id}"

          roller = new ReminderRoller reminder
          roller.schedule robot, ->
            robot.logger.info "Removing reminder #{reminder.id}"
            roller.remove robot

        rebooted.push reminder

    robot.brain.set REMINDER_STORE_NAME, rebooted

module.exports.me = (robot, roomName, days, message) ->
  reminder = new Reminder days, roomName, message
  roller = new ReminderRoller reminder
  roller.schedule robot, ->
    robot.logger.info "Removing reminder #{reminder.id}"
    roller.remove robot

  robot.messageRoom roomName, "Dodałem przypomnienie na dzień #{reminder.scheduleDate}!"

  reminders = robot.brain.get REMINDER_STORE_NAME or []
  reminders.push reminder
  robot.brain.set REMINDER_STORE_NAME, reminders
