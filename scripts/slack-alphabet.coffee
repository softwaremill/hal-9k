# Description:
#   Translate a give word/sentence into Slack Alphabet
#
# Dependencies:
#   None
#
# Commands:
#   hubot translate|tłumacz|tlumacz <text> - translates the <text>


module.exports = (robot) ->
  robot.respond /(translate|tłumacz|tlumacz) (.*)/i, (res) ->
    word = res.match[2]
    translated = for char in word
      if char == ' '
        char
      else
        ":alphabet-white-#{char}:"

    robot.send translated
