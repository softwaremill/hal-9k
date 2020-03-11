# Description:
#   Echos all the traffic to the log. Use only when debugging and switch off when done!

enabled = false

module.exports = (robot) ->

  if enabled
    robot.hear /.*/i, (msg) ->
      robot.logger.info(msg)
