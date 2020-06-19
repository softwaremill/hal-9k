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

  if robot.slackMessages
    robot.logger.info "robot.slackMessages already defined"
    return

  slackMessages = createMessageAdapter process.env.HUBOT_SLACK_SIGNING_SECRET
  robot.slackMessages = slackMessages

  loggingMiddleware = (req, res, next) ->
    robot.logger.info req.body
    next()

  messageMiddleware = slackMessages.expressMiddleware()

  handlers = [loggingMiddleware, messageMiddleware]

  robot.router.post '/slack/actions', handlers
