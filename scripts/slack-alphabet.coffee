# Description:
#   Translate a give word/sentence into Slack Alphabet
#
# Dependencies:
#   None
#
# Commands:
#   hubot translate|tłumacz|tlumacz <text> - translates the <text>

_ = require 'lodash'

module.exports = (robot) ->

  robot.respond /(translate|tłumacz|tlumacz) (.*)/i, (res) ->
    robot.logger.info "Got sentence to translate: #{res.match[2]}"

    word = res.match[2]
    translated = for char in word
      lowered = char.toLowerCase()
      if lowered == ' '
        '  '
      else
        ":alphabet-white-#{_.deburr lowered}:"

    msg = translated.reduce (x, y) -> x + y
    robot.logger.info "Translated: #{msg}"

    response =
      type: "mrkdwn"
      text: msg

    res.send response
