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

  slackMessages = createMessageAdapter process.env.HUBOT_SIGNING_SECRET
  robot.slackMessages = slackMessages

  robot.router.post '/slack/actions', slackMessages.expressMiddleware()
