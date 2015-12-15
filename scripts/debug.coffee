# Description:
#   Echos all the traffic to the log. Use only when debugging and switch off when done!

enabled = false

module.exports = (robot) ->

  robot.hear /.*/i, (msg) ->
    if enabled
      robot.logger.info(msg)
