# Description:
#   Records mood for users
#
# Commands:
#   when leaving the work Hubot will record the mood (1-5)

moodDao = require './mood/moodDao'

module.exports = (robot) ->
  recordMood = (res) ->
    mood = parseInt(res.match[1])
    if mood < 1 or mood > 5
      remindMoodQuestion(res)
    else
      moodDescription = res.match[2]
      moodDao.addMood(robot, res, mood, moodDescription)

  remindMoodQuestion = (res) ->
    res.reply "Hej jak Ci minął dzień? Napisz `/me out [nastrój 1-5] [opcjonalnie pare słów co się działo]`"

  robot.hear /^out (\d+)\w?(.*)?/i, recordMood
  robot.hear /^out\s?(\D.*)?$/i, remindMoodQuestion
