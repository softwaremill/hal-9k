# Description:
#   Drover - utility to setup up reminder in cron based format.
#
# Commands:
#   hubot cron list - lists all the defined reminders
#   hubot cron "<message>" at "<cron expression>" on "<channel name with #> - adds new reminder for given cron expression and channel
#   hubot cron "<message>" at "<cron expression>" - adds new reminder for given cron expression for defaul channel (#!_wazne_)
#   hubot cron delete <number> - deletes reminder for given index (to check index type "hubot cron list")
#   hubot cron show   <number> - prints full job definition for given index (to check index type "hubot cron list")

CronJob = require('cron').CronJob

timeZone = 'Europe/Amsterdam'
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

  getNiceMessage: ->
    if @message.length > 50
      return "#{@message.substring(0, 50)}(...)"
    return @message

  getDefinition: ->
    return "#{@message}\" at \"#{@cronExpr}\" on \"#{@channel}\""

  toString: ->
    return "#{@getNiceMessage()} (expr: #{@cronExpr} channel: #{@channel})"

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
    jobName = msg.match[1]
    jobCronExpr = msg.match[2]
    jobChannel = msg.match[3]
    try
      jobManager.addJob jobName, jobCronExpr, jobChannel
    catch error
      msg.reply error

  robot.respond /cron "(.*)" at "([^"]*)"$/i, (msg) ->
    jobName = msg.match[1]
    jobCronExpr = msg.match[2]
    try
      jobManager.addJob jobName, jobCronExpr
    catch error
      msg.reply error

  robot.respond /cron list/i, (msg) ->
    jobs = jobManager.jobs
    msg.reply "#{i} : #{jobs[i]}" for job, i in jobs
    msg.reply "You can remove cron job with: cron delete (number)."
    msg.reply "For more details go to https://kiwi.softwaremill.com/display/ORG/Automatyczne+przypomnienia+z+Januszem"

  robot.respond /cron delete all/i, (msg) ->
    jobManager.removeAll()
    msg.reply "All jobs stopped."

  robot.respond /cron delete (\d+)/i, (msg) ->
    jobIndex = msg.match[1]
    job = jobManager.remove(jobIndex)
    if(job?)
      msg.reply "Job removed: #{job}"
    else
      msg.reply "No job with index #{jobIndex}"

  robot.respond /cron show (\d+)/i, (msg) ->
    jobIndex = msg.match[1]
    job = jobManager.get(jobIndex)
    if(job?)
      msg.reply "Job: #{job.getDefinition()}"
    else
      msg.reply "No job with index #{jobIndex}"
    
      