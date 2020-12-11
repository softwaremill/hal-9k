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
    robot.logger.info "Got sentence to translate: #{res.match[2]}"

    word = res.match[2]
    translated = for char in word
      c = char.toLowerCase()
      if c == ' '
        char
      else
        ":alphabet-white-#{c}:"

    msg = translated.reduceRight (x, y) -> x + y
    robot.logger.info "Translated: #{msg}"

    response =
      type: "mrkdwn"
      text: msg

    res.send response
