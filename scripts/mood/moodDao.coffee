backend = require '../common/backend'

errorHandler = (messageResponse) ->
  (err, errCode) -> messageResponse.reply("Error #{errCode}")

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
