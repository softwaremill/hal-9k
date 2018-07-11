# Description:
#   To add and show kudos
#
# Commands:
#   hubot kudos help - pokazuje pomoc dla modułu kudos
#

users = require './common/users'
kudos = require './kudos/kudosDao'
{ RTMClient } = require "@slack/client"
 
module.exports = (robot) ->
  slackToken = process.env.HUBOT_SLACK_TOKEN
  client = new RTMClient(slackToken)
  apiUrl = process.env.SLACK_API_URL
  client.start()
  robot.logger.info('reactions listener started')

  prepareFindMessageRequest = (event) ->
    reactingUser = event.user
    channel = event.item.channel
    messageId = event.item.ts

    return robot.http("#{apiUrl}/channels.history?channel=#{channel}&latest=#{messageId}&inclusive=true&count=1")
    .header('Content-Type', 'application/json')
    .header('Authorization', "Bearer #{slackToken}")

  handlePlusedKudos = (kudosReceiver, kudosDesc) ->
    user = users.getUser(robot, kudosReceiver)
    

    if user == undefined
      allUsers = users.getAllUsers(robot).map((u) -> { name: u.name, id: u.id })
      robot.logger.error("user list: #{JSON.stringify allUsers}")
      robot.logger.error("user #{kudosReceiver} not found")
    else
      successHandler = (successBody) ->
        userKudos = JSON.parse(successBody)
        plusedKudo = userKudos.find((kudo) -> kudo.description == kudosDesc)

        if plusedKudo
          kudos.addPlusOne(
            robot,
            (body) ->
              jsonBody = JSON.parse(body)
              robot.logger.info(if jsonBody.message? then jsonBody.message else body)
            ,
            (err, errCode) ->
              robot.logger.info("Error #{errCode}")
            ,
            user.id,
            plusedKudo.id,
            plusedKudo.description
          )

        else
          robot.logger.error("kudo #{kudosDesc} not found in #{successBody}")

      errorHandler = (err) ->
        robot.logger.error("err while retreiving user kudos #{kudosReceiver}")

      kudos.getKudos(robot, user.id, successHandler, errorHandler)



  handlePlusOneReaction = (event) ->
    prepareFindMessageRequest(event)
    .get() (err, res, body) ->
      if err
        robot.logger.err(err)
      else
        data = JSON.parse body
        
        if data.messages
          messageText = data.messages[0].text
          textMatch = messageText.match(/kudos (add|dodaj) @?(\S*) (.*)/i)

          if textMatch
            kudosReceiver = textMatch[2].replace(/(<|>|@)/g, '')
            kudosDesc = textMatch[3]
            handlePlusedKudos(kudosReceiver, kudosDesc)

        else
          robot.logger.error('No messages found')


  reactionsListener = (event) ->
    robot.logger.info('reactions: ', JSON.stringify(event))

    if (event.reaction == '+1')
      handlePlusOneReaction(event)





  client.on 'reaction_added', reactionsListener

