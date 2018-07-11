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

  reactionsListener = (event, sthElse) ->
    robot.logger.info('reactions: ', JSON.stringify(event))
    robot.logger.info('sthElse: ', JSON.stringify(sthElse))

    if (event.reaction == '+1')
      reactingUser = event.user
      channel = event.item.channel
      messageId = event.item.ts

      robot.http("#{apiUrl}/channels.history?channel=#{channel}&latest=#{messageId}&inclusive=true&count=1")
      .header('Content-Type', 'application/json')
      .header('Authorization', "Bearer #{slackToken}")
      .get() (err, res, body) ->
        if err
          robot.logger.err(err)
          res.send('error: ', err)
        else
          data = JSON.parse body
          
          if data.messages
            messageText = data.messages[0].text
            textMatch = messageText.match(/kudos (add|dodaj) @?(\S*) (.*)/i)

            if textMatch
              kudosReceiver = textMatch[2]
              kudosDesc = textMatch[3]

              user = users.getUser(robot, kudosReceiver)
              if user == undefined
                robot.logger.err("user #{kudosReceiver} not found")
              else
                successHandler = (successBody) ->
                  userKudos = JSON.parse(successBody)
                  plusedKudo = userKudos.find((kudo) -> kudo.description == kudosDesc)

                  if plusedKudo
                    kudos.addPlusOne(
                      robot,
                      (body) ->
                        res.reply(if jsonBody.message? then jsonBody.message else successBody)
                      ,
                      (err, errCode) ->
                        res.reply("Error #{errCode}")
                      ,
                      user.id,
                      plusedKudo.id,
                      plusedKudo.description
                    )

                  else
                    robot.logger.err("kudo #{kudosDesc} not found in #{successBody}")

                errorHandler = (err) ->
                  robot.logger.err("err while retreiving user kudos #{kudosReceiver}")


                kudos.getKudos(robot, user.id, successHandler, errorHandler)


          else
            robot.logger.err('No messages found')




  client.on 'reaction_added', reactionsListener

