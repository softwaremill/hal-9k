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

  loggingMiddleware = (req, res, next) ->
    robot.logger.info req.body
    next()

  handlers = [loggingMiddleware, slackMessages.expressMiddleware]

  robot.router.post '/slack/actions', handlers
