# Description:
#   Records mood for users
#
# Commands:
#   when leaving the work Hubot will record the mood (1-5)

VALID_MOOD_COMMAND_REGEXP = /^out (\d+)\w?(.*)?/i
INVALID_MOOD_COMMAND_REGEXP = /^out(\s\D.*)?$/i
COMMAND_USAGE_DESCRIPTION = "Hej jak Ci minął dzień? Napisz `/me out [nastrój 1-5] [opcjonalnie pare słów co się działo]`"

moodDao = require './mood/moodDao'
{ RTMClient } = require "@slack/client"

module.exports = (robot) ->
  slackToken = process.env.HUBOT_SLACK_TOKEN
  client = new RTMClient(slackToken)
  client.start()

  recordMood = (res) ->
    mood = parseInt(res.match[1])
    if mood < 1 or mood > 5
      remindMoodQuestion(res)
    else
      moodDescription = res.match[2]
      moodDao.addMood(robot, res, mood, moodDescription)

  remindMoodQuestion = (res) ->
    res.reply COMMAND_USAGE_DESCRIPTION

  recordMoodFromEvent = (event, client) ->
    client.sendMessage("This will be working very soon!", event.channel)

  remindMoodQuestionFromEvent = (event, client) ->
    client.sendMessage(COMMAND_USAGE_DESCRIPTION, event.channel)

  robot.hear VALID_MOOD_COMMAND_REGEXP, recordMood
  robot.hear INVALID_MOOD_COMMAND_REGEXP, remindMoodQuestion

  meMessageListener = (event) ->
    if (event.subtype == 'me_message')
      robot.logger.info("Me message = #{JSON.stringify(event)}")
      if (event.text.match(VALID_MOOD_COMMAND_REGEXP))
        recordMoodFromEvent(event, client)
      else if (event.text.match(INVALID_MOOD_COMMAND_REGEXP))
        remindMoodQuestionFromEvent(event, client)

  client.on 'message', meMessageListener