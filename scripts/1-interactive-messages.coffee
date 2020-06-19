# Description
#   A hubot script that supports Slack's Interactive Messages
#
# Configuration:
#    none
#
# URLs:
#   POST /slack/actions
#

{ createMessageAdapter } = require '@slack/interactive-messages'

module.exports = (robot) ->

  slackMessages = undefined

  slackMessages = createMessageAdapter process.env.HUBOT_SLACK_SIGNING_SECRET
  robot.slackMessages = slackMessages

  loggingMiddleware = (req, res) ->
    robot.logger.info "Request: #{req}"
    robot.logger.info "Response: #{res}"

  handlers = [loggingMiddleware, slackMessages.expressMiddleware()]

  robot.router.post '/slack/actions', loggingMiddleware
