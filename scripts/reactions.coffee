# Description:
#   To add and show kudos
#
# Commands:
#   hubot kudos help - pokazuje pomoc dla modułu kudos
#

users = require './common/users'
kudos = require './kudos/kudosDao'
{WebClient} = require "@slack/client"
 
module.exports = (robot) ->
  web = new WebClient(process.env.HUBOT_SLACK_TOKEN)
  robot.logger.info('reactions listener started')

  rawMessageListener = (msg) ->
    if msg.type == "reaction_removed" or msg.type == "reaction_added"
      robot.logger.info('reactions: ', JSON.stringify(msg))

  web.on 'raw_message', rawMessageListener

