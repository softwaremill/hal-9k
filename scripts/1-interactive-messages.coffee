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

  loggingMiddleware = (res, req, query) ->
    robot.logger.info "Response: #{res}"
    robot.logger.info "Request: #{req}"
    robot.logger.info "Query: #{query}"

  handlers = [slackMessages.expressMiddleware(), loggingMiddleware]

  robot.router.post '/slack/actions', handlers
