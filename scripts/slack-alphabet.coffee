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
    robot.logger.info "Got translate command: #{res.match[1]}"

    word = res.match[1]
    translated = for char in word
      c = char.toLowerCase
      if c == ' '
        char
      else
        ":alphabet-white-#{c}:"

    robot.send translated
