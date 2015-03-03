module.exports = (robot) ->
  robot.respond /multiline\s?((.*\s*)+)/i, (msg) ->
    msg.reply msg.match[2..].join('#')
