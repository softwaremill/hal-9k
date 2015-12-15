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
    robot.logger.info(jsonBody)
    messageResponse.reply("Trzymaj się, do jutra!")

  backend.post("/rest/mood", data, robot, successHandler, errorHandler(messageResponse))
