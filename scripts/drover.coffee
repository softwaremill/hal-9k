CronJob = require('cron').CronJob

timeZone = 'Europe/Amsterdam'
defaultChannel = '#hubottest'

class Job

  constructor: (@message, @cronExpr, @jobChannel, robot) ->
    @cronJob = new CronJob("* " + cronExpr, ( ->
      robot.messageRoom(jobChannel, message)
    ), null, true, timeZone)

  start: ->
    @cronJob.start()

  stop: ->
    @cronJob.stop()

  getNiceMessage: ->
    if(@message.length > 50)
      return "#{@message.substring(0, 50)}(...)"
    return @message

  toString: ->
    return "#{@getNiceMessage()} (expr: #{@cronExpr} channel: #{@jobChannel})"

class JobManager

  constructor: (@robot) ->
    @jobs = []

  addJob: (message, cronExpr, jobChannel) ->
    channel = if jobChannel? then jobChannel else defaultChannel
    newJob = new Job(message, cronExpr, channel, @robot)
    newJob.start()
    @jobs.push(newJob)

  removeAll: ->
    job.stop() for job in @jobs
    @jobs = []

  remove: (jobIndex) ->
    if(jobIndex < @jobs.length)
      job = @jobs[jobIndex]
      job.stop()
      @jobs.splice(jobIndex, 1)
      return job
    return null

module.exports = (robot) ->
  jobManager = new JobManager(robot)
  jobManager.addJob("Wysylac faktury patalachy!", '1 * * * *')

  robot.respond /cron "(.*)" at "(.*)" on "(.*)"/i, (msg) ->
    jobName = msg.match[1]
    jobCronExpr = msg.match[2]
    jobChannel = msg.match[3]
    try
      jobManager.addJob(jobName, jobCronExpr, jobChannel)
    catch error
      msg.reply(error)

  robot.respond /cron "(.*)" at "([^"]*)"$/i, (msg) ->
    jobName = msg.match[1]
    jobCronExpr = msg.match[2]
    try
      jobManager.addJob(jobName, jobCronExpr)
    catch error
      msg.reply(error)


  robot.respond /cron list/i, (msg) ->
    jobs = jobManager.jobs
    msg.reply("#{i} : #{jobs[i].toString()}") for job, i in jobs
    msg.reply("You can remove cron job with: cron delete (number).")

  robot.respond /cron delete all/i, (msg) ->
    jobManager.removeAll()
    msg.reply("All jobs stopped.")

  robot.respond /cron delete (\d+)/i, (msg) ->
    jobIndex = msg.match[1]
    job = jobManager.remove(jobIndex)
    if(job?)
      msg.reply("Job removed: #{job.toString()}")
    else
      msg.reply("No job with index #{jobIndex}")



          


  
  
  

    
    
    
    
