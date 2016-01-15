REMINDER_STORE_NAME = '__reminder_store'

restoreReminder = (json) =>
  scheduleDate = new Date(json.scheduleDate)
  reminder = new Reminder json.id, scheduleDate, json.roomName, json.message

  reminder

class Reminder
  constructor: (@id, @scheduleDate, @roomName, @message) ->

  isExpired: =>
    @scheduleDate.getTime() <= new Date().getTime()

class ReminderRoller

  constructor: (reminder) ->
    @id = reminder.id
    @roomName = reminder.roomName
    @message = reminder.message
    @scheduleDate = reminder.scheduleDate

  schedule: (robot, done) =>
    timeout = @calcTimeout()

    robot.logger.info "Scheduling job at #{@scheduleDate} - #{timeout}"

    setTimeout =>
        @run robot, done
      ,
      timeout

  calcTimeout: ->
    timeout = @scheduleDate.getTime() - new Date().getTime()
    if timeout <= 0
      timeout = 2000

    timeout

  run: (robot, done) =>
    robot.messageRoom @roomName, @message
    done()

  remove: (robot) ->
    reminders = robot.brain.get(REMINDER_STORE_NAME) or []
    cleared = []

    for reminder in reminders
      if reminder?.id != @id
        robot.logger.info "Preserving reminder with id #{reminder.id} as it is different than this id #{@id}"
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

    reminders = robot.brain.get(REMINDER_STORE_NAME) or []
    rebooted = []

    robot.logger.info "Existing reminders:"
    robot.logger.info JSON.stringify reminders

    for reminder in reminders
      if reminder
        if reminder.isExpired
          robot.logger.info "Reminder #{reminder.id} expired, run it now!"

          roller = new ReminderRoller restoreReminder(reminder)
          roller.run robot, ->

        else
          robot.logger.info "Re-scheduling reminder #{reminder.id}"

          roller = new ReminderRoller restoreReminder(reminder)
          roller.schedule robot, ->
            robot.logger.info "Removing reminder #{reminder.id}"
            roller.remove robot

          rebooted.push reminder

    robot.logger.info "Storing rebooted reminders: #{rebooted.length}"

    robot.brain.set REMINDER_STORE_NAME, rebooted

module.exports.me = (robot, roomName, days, message) ->

  scheduleDate = new Date()
  scheduleDate.setDate scheduleDate.getDate() + days
  id = Math.round scheduleDate.getTime() * Math.random()

  reminder = new Reminder id, scheduleDate, roomName, message

  roller = new ReminderRoller reminder
  roller.schedule robot, ->
    robot.logger.info "Removing reminder #{reminder.id}"
    roller.remove robot

  robot.messageRoom roomName, "Dodałem przypomnienie na dzień #{reminder.scheduleDate}!"

  reminders = robot.brain.get(REMINDER_STORE_NAME) or []
  reminders.push reminder
  robot.brain.set REMINDER_STORE_NAME, reminders
