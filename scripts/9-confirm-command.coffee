# Description
#   A hubot script that adds support to confirm performed operation by the bot
#
# Configuration:
#    none

module.exports = (robot) ->

  if robot.slackConfirm
    robot.logger.info "robot.slackConfirm already defined"
    return

  robot.slackConfirm = (res, message) ->
    response = robot.adapter.client.web.reactions.add(
      'white_check_mark',
      {
        channel: res.message.rawMessage.channel
        timestamp: res.message.id
      }
    )
    response
      .then (result) ->
        robot.logger.info result
        if message
          robot.messageRoom res.message.user.id, message
      .catch (error) ->
        robot.logger.error error
        if message
          robot.messageRoom res.message.user.id, "#{message} Ale nie mogłem potwierdzić wykonania operacji, bo: #{error}"
