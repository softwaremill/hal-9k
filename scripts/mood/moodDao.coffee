backend = require '../common/backend'
users = require '../common/users'

errorHandler = (messageResponse) ->
  (err, errCode) -> messageResponse.reply("Error #{errCode}")

errorHandlerForEvent = (event, robot) ->
  (err, errCode) -> robot.messageRoom event.channel, "Error #{errCode}"

module.exports.addMood = (robot, messageResponse, mood, description) ->
  robot.logger.info("message: #{messageResponse}");
  robot.logger.info("mood: #{mood}");
  robot.logger.info("description: #{description}");
  data = {
    userName: messageResponse.message.user.name,
    userId: messageResponse.message.user.id,
    mood: mood,
    description: description?.trim(),
  }

  successHandler = (successBody) ->
    jsonBody = JSON.parse(successBody)
    if (jsonBody.message == "ok")
      if (new Date().getDay() == 5)
        messageResponse.reply("Miłego weekendu! Do poniedziałku.")
      else
        messageResponse.reply("Trzymaj się, do jutra!")
    else
      robot.logger.info("Bad response from janusz mood storage!")
      robot.logger.info(jsonBody)
      messageResponse.reply("Coś znowu poszło nie tak. @grzesiek, raaaaatuj!")

  backend.post("/rest/mood", data, robot, successHandler, errorHandler(messageResponse))

module.exports.addMoodFromEvent = (event, robot, mood, description) ->
  robot.logger.info("event: #{JSON.stringify(event)}");
  robot.logger.info("mood: #{mood}");
  robot.logger.info("description: #{description}");
  data = {
    userName: users.getUserById(robot, event.user).name
    userId: event.user,
    mood: mood,
    description: description?.trim(),
  }
  robot.logger.info("data = #{JSON.stringify(data)}")

  successHandler = (successBody) ->
    jsonBody = JSON.parse(successBody)
    if (jsonBody.message == "ok")
      if (new Date().getDay() == 5)
        robot.messageRoom event.channel, "Miłego weekendu! Do poniedziałku."
      else
        robot.messageRoom event.channel, "Trzymaj się, do jutra @#{event.user.name}!"
    else
      robot.logger.info("Bad response from janusz mood storage!")
      robot.logger.info(jsonBody)
      robot.messageRoom event.channel, "Coś znowu poszło nie tak. @grzesiek, raaaaatuj!"

  backend.post("/rest/mood", data, robot, successHandler, errorHandlerForEvent(event, robot))


module.exports.getMoodStats = (robot, messageResponse) ->
  robot.logger.info("Fetching mood stats since 2015");
  backend.get("/rest/mood-stats/monthly", robot,
    (successBody) ->
      jsonBody = JSON.parse(successBody)
      messageText = "*Średni nastrój w firmie na podstawie nastrojów (mood) w skali 1-5*\n"

      for i in [0..jsonBody.length-1]
        messageText += " - " + jsonBody[i].yearMonth + ": " + jsonBody[i].averageMood + "\n"
      messageResponse.reply(messageText)
    ,
    errorHandler(messageResponse)
  )

module.exports.getMoodStatsForMonth = (robot, messageResponse, year, month) ->
  robot.logger.info("Fetching moods stats for #{year}-#{month}");
  backend.get("/rest/mood-stats/monthly/#{year}/#{month}", robot,
    (successBody) ->
      jsonBody = JSON.parse(successBody)
      messageResponse.reply("Średni nastrój [1-5] w firmie w miesiącu #{jsonBody.yearMonth}: #{jsonBody.averageMood}")
  ,
    errorHandler(messageResponse)
  )

module.exports.getRecentMoodStats = (robot, messageResponse, numberOfDays) ->
  robot.logger.info("Fetching recent moods stats since last #{numberOfDays} days");
  backend.get("/rest/mood-stats/recent/#{numberOfDays}", robot,
    (successBody) ->
      jsonBody = JSON.parse(successBody)
      messageText = "*Najniższy nastrój w firmie w ostatnich #{numberOfDays} dniach:*\n"

      for i in [0..jsonBody.length-1]
        twoDigitValueAfterCommaMood = (Math.round(jsonBody[i].averageMood * 100) / 100).toFixed(2);
        messageText += " #{i+1}. #{jsonBody[i].userName}: #{twoDigitValueAfterCommaMood} (ilość danych: #{jsonBody[i].numberOfMoodData})\n"
      messageResponse.reply(messageText)
  ,
    errorHandler(messageResponse)
  )