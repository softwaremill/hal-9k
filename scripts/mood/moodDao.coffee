backend = require '../common/backend'

errorHandler = (messageResponse) ->
  (err, errCode) -> messageResponse.reply("Error #{errCode}")

errorHandlerForEvent = (event, client) ->
  (err, errCode) -> client.sendMessage("Error #{errCode}", event.channel)

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

module.exports.addMoodFromEvent = (client, event, robot, mood, description) ->
  robot.logger.info("event: #{JSON.stringify(event)}");
  robot.logger.info("mood: #{mood}");
  robot.logger.info("description: #{description}");
  data = {
    userName: ''
    userId: event.user,
    mood: mood,
    description: description?.trim(),
  }
  robot.logger.info("data = #{JSON.stringify(data)}")

  successHandler = (successBody) ->
    jsonBody = JSON.parse(successBody)
    if (jsonBody.message == "ok")
      if (new Date().getDay() == 5)
        client.sendMessage("Miłego weekendu! Do poniedziałku.", event.channel)
      else
        client.sendMessage("Trzymaj się, do jutra!", event.channel)
    else
      robot.logger.info("Bad response from janusz mood storage!")
      robot.logger.info(jsonBody)
      client.sendMessage("Coś znowu poszło nie tak. @grzesiek, raaaaatuj!", event.channel)

  backend.post("/rest/mood", data, robot, successHandler, errorHandlerForEvent(event, client))
