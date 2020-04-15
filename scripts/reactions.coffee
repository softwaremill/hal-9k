# Description:
#   To add and show kudos
#
# Commands:
#   hubot kudos help - pokazuje pomoc dla modułu kudos
#

users = require './common/users'
kudos = require './kudos/kudosDao'
fourthQuestion = require './fourth_question/FourthQuestionDao'
{RTMClient} = require "@slack/client"
slackUtils = require './common/slack-utils'

module.exports = (robot) ->
  slackToken = process.env.HUBOT_SLACK_TOKEN
  client = new RTMClient(slackToken)
  client.start()

  handlePlusedKudos = (kudosReceiver, kudosDesc, reactingUser) ->
    user = users.getAllUsers(robot).find((u) -> u.id == kudosReceiver || u.name == kudosReceiver)
    robot.logger.error("user #{kudosReceiver}")

    if user == undefined
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
            (err, errCode) ->
              robot.logger.info("Error #{errCode}")
            reactingUser,
            plusedKudo.id,
            plusedKudo.description
          )

        else
          robot.logger.error("kudo #{kudosDesc} not found in #{successBody}")

      errorHandler = (err) ->
        robot.logger.error("err while retreiving user kudos #{kudosReceiver}")

      kudos.getKudos(robot, user.id, successHandler, errorHandler)


  handlePlusOneReaction = (event) ->
    reactingUser = event.user

    slackUtils.prepareFindMessageRequest(robot, event).get() (err, res, body) ->
      if err
        robot.logger.error(err)
      else
        data = JSON.parse body

        if data.messages
          messageText = data.messages[0].text
          textMatch = messageText.match(/kudos (add|dodaj) @?(\S*) (.*)/i)

          if textMatch
            kudosReceiver = textMatch[2].replace(/(<|>|@)/g, '')
            kudosDesc = textMatch[3]
            handlePlusedKudos(kudosReceiver, kudosDesc, reactingUser)

        else
          robot.logger.error('No messages found')

  reactionsListener = (event) ->
    if (event.reaction == '+1')
      handlePlusOneReaction(event)

  client.on 'reaction_added', reactionsListener

