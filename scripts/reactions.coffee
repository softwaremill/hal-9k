# Description:
#   To add and show kudos
#
# Commands:
#   hubot kudos help - pokazuje pomoc dla modułu kudos
#

users = require './common/users'
kudos = require './kudos/kudosDao'
{RTMClient} = require "@slack/client"
 
module.exports = (robot) ->
  client = new RTMClient(process.env.HUBOT_SLACK_TOKEN)
  client.start()
  robot.logger.info('reactions listener started')

  rawMessageListener = (event) ->
    robot.logger.info('reactions: ', JSON.stringify(event))

  client.on 'reaction_added', rawMessageListener

