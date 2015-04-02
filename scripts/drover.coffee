CronJob = require('cron').CronJob

timeZone = 'Europe/Amsterdam'
defaultChannel = 'hubottest'

class JobManager

  constructor: (@robot) ->
    @jobs = []

  addJob: (message, cronExpr, jobChannel) ->
    temp = @robot
    channel = if jobChannel? then jobChannel else defaultChannel
    newJob = new CronJob("* " + cronExpr, ( ->
      temp.messageRoom(channel, message)
    ), null, true, timeZone)
    newJob.job_name = message
    newJob.cronExpr = cronExpr
    newJob.start()
    newJob.getName = ->
      if(this.job_name.length > 50)
        return "#{this.job_name.substring(0, 50)}  (...)"
      return this.job_name
    newJob.toMessage = ->
      return "#{this.getName()} ( #{this.cronExpr} )"
    @jobs.push(newJob)

  removeAll: ->
    for job in @jobs
      do(job) -> job.stop()
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
    i = 0
    jobs = jobManager.jobs
    while i < jobs.length
      msg.reply "#{i} : #{jobs[i].toMessage()}"
      i++
    msg.reply "You can remove cron job with: cron delete (number)"

  robot.respond /cron delete all/i, (msg) ->
    jobManager.removeAll()
    msg.reply "All jobs stoped"

  robot.respond /cron delete (\d+)/i, (msg) ->
    jobIndex = msg.match[1]
    job = jobManager.remove(jobIndex)
    if(job != null)
      msg.reply "Job removed: #{job.getName()}"
    else
      msg.reply "No job with index #{jobIndex}"



          


  
  
  

    
    
    
    
