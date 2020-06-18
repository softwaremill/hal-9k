# Description:
#   Hubot will react on different names

module.exports = (robot) ->
  robot.hear /^(januszu)? (.+)/i, (res) ->
    res.finish()

    robot.logger.info "Catching: #{res.match[1]} #{res.match[2]}"

    message = res.message
    message.done = false
    message.text = message.text.replace(res.match[1], robot.name)

    robot.logger.info "Reroute message back to robot #{robot.name}"
    robot.receive message
    return
