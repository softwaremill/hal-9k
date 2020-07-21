# Description:
#   Drover - utility to setup up reminder in cron based format.
#
# Commands:
#   hubot cron help|pomoc|? - shows help message
#

CronJob = require('cron').CronJob

timeZone = 'Europe/Warsaw'
defaultChannel = '#_wazne_'

CRON_JOBS_LIST = "CRON_JOBS_LIST"

class Job

  constructor: (@message, @cronExpr, @channel, functionToCall) ->
    @cronJob = new CronJob "0 " + cronExpr,
      ->
        functionToCall(channel, message)
    , null, true, timeZone

  start: ->
    @cronJob.start()

  stop: ->
    @cronJob.stop()

  getDefinition: ->
    return "\"#{@message}\" at \"#{@cronExpr}\" on \"#{@channel}\""

  toString: ->
    return "#{@message} (expr: #{@cronExpr} channel: #{@channel})"

  toMap: -> {message: @message, cronExpr: @cronExpr, channel: @channel}

class JobManager

  constructor: (@getJobsFunction, @saveJobsFunction, @functionToCall)->
    @initJobs(getJobsFunction, functionToCall)

  initJobs: (getJobsFunction, functionToCall) ->
    loadedJobs = getJobsFunction()
    if(loadedJobs?)
      @jobs = loadedJobs.filter((x)-> x?).map((map)-> new Job(map.message, map.cronExpr, map.channel, functionToCall))
    else @jobs = []

  saveJobs: ->
    @saveJobsFunction(@jobs.map (job) -> job.toMap())

  addJob: (message, cronExpr, jobChannel) ->
    channel = jobChannel or defaultChannel
    newJob = new Job(message, cronExpr, channel, @functionToCall)
    newJob.start()
    @jobs.push newJob
    @saveJobs()

  removeAll: ->
    job.stop() for job in @jobs
    @jobs = []
    @saveJobs()

  remove: (jobIndex) ->
    if jobIndex < @jobs.length
      job = @jobs[jobIndex]
      job.stop()
      @jobs.splice jobIndex, 1
      @saveJobs()
      return job
    return null

  get: (jobIndex) ->
    if jobIndex < @jobs.length
      job = @jobs[jobIndex]
      return job
    return null


module.exports = (robot) ->
  getJobs = ->
    loadedJobs = robot.brain.get(CRON_JOBS_LIST)
    return loadedJobs

  saveJobs = (jobs)->
    robot.brain.set(CRON_JOBS_LIST, jobs)

  remind = (channel, message) ->
    robot.messageRoom channel, message

  jobManager = null
  robot.brain.on "loaded", =>
    if jobManager is null
      jobManager = new JobManager(getJobs, saveJobs, remind)

  robot.respond /cron "(.*)" at "(.*)" on "(.*)"/i, (msg) ->
    msg.finish()
    robot.logger.info "Got cron command: #{msg.message.text}"
    jobName = msg.match[1]
    jobCronExpr = msg.match[2]
    jobChannel = msg.match[3]
    robot.logger.info("Adding cron job: message=#{jobName}; cron=#{jobCronExpr}; channel=#{jobChannel}")
    try
      jobManager.addJob jobName, jobCronExpr, jobChannel
      msg.send ":+1:"
    catch error
      robot.logger.error("Couldn't add new cron job: #{error}")
      msg.reply error

  robot.respond /cron "(.*)" at "([^"]*)"$/i, (msg) ->
    msg.finish()
    jobName = msg.match[1]
    jobCronExpr = msg.match[2]
    robot.logger.info("Adding cron job to default channel(#{defaultChannel}): message=#{jobName}; cron=#{jobCronExpr}")
    try
      jobManager.addJob jobName, jobCronExpr
      msg.send ":+1:"
    catch error
      robot.logger.error("Couldn't add new cron job to default channel: #{error}")
      msg.reply error

  robot.respond /cron list/i, (msg) ->
    if jobManager is null
      msg.reply "Jobs loading in progress..."
      return

    attachments = []
    jobs = jobManager.jobs
    for job, index in jobs
      attachments.push
        text: "#{index}: #{jobs[index].message}\n Expr: `#{jobs[index].cronExpr}` on #{jobs[index].channel}",
        mrkdwn_in: ["text"]

    response =
      text: "Defined jobs"
      attachments: attachments
      username: robot.name
      as_user: true

    msg.send response
    msg.send """
      You can remove cron job with: `cron delete <number>`, for more details go to <https://softwaremill.atlassian.net/l/c/y6Z1Fxpi)|Kiwi>
    """

  robot.respond /cron delete all/i, (msg) ->
    jobManager.removeAll()
    msg.send "All wiped out!"

  robot.respond /cron delete (\d+)/i, (msg) ->
    jobIndex = msg.match[1]
    job = jobManager.remove(jobIndex)
    if(job?)
      msg.send "Job with index #{jobIndex} was removed!"
    else
      msg.reply "No job with index #{jobIndex}"

  robot.respond /cron show (\d+)/i, (msg) ->
    jobIndex = msg.match[1]
    if jobManager is null
      msg.reply "Jobs loading in progress..."
      return
    job = jobManager.get(jobIndex)
    if(job?)
      msg.send "Job: #{job.getDefinition()}"
    else
      msg.send "No job with index #{jobIndex}"

  robot.respond /cron (help|pomoc|\?)$/i, (msg) ->
    msg.send """
      cron list - lists all the defined reminders
      cron "<message>" at "<cron expression>" on "<channel name with #>" - adds new reminder for given cron expression and channel
      cron "<message>" at "<cron expression>" - adds new reminder for given cron expression for default channel `#{defaultChannel}`
      cron delete <number> - deletes reminder for given index (to check index type `hubot cron list`)
      cron show   <number> - prints full job definition for given index (to check index use `hubot cron list`)
    """
