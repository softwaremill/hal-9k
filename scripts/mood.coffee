# Description:
#   Records mood for users
#
# Commands:
#   when leaving the work Hubot will record the mood (1-5)

moodDao = require './mood/moodDao'

module.exports = (robot) ->
  recordMood = (res) ->
    mood = res.match[1]
    moodDescription = res.match[2]
    moodDao.addMood(robot, res, mood, moodDescription)

  remindMoodQuestion = (res) ->
    res.reply "Hej @#{res.message.user.name} jak Ci minął dzień? Napisz `/me out [nastrój 1-5] [opcjonalnie pare słów co się działo]`"

  robot.hear /\/me out (\d)\w?(.*)?/i, recordMood
  robot.hear /\/me out$/i, remindMoodQuestion
