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
  slackToken = process.env.HUBOT_SLACK_TOKEN
  client = new RTMClient(slackToken)
  apiUrl = process.env.SLACK_API_URL
  client.start()

  prepareFindMessageRequest = (event) ->
    channel = event.item.channel
    messageId = event.item.ts

    return robot.http("#{apiUrl}/channels.history?channel=#{channel}&latest=#{messageId}&inclusive=true&count=1")
      .header('Content-Type', 'application/json')
      .header('Authorization', "Bearer #{slackToken}")

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
          ,
            (err, errCode) ->
              robot.logger.info("Error #{errCode}")
          ,
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

    prepareFindMessageRequest(event).get() (err, res, body) ->
      if err
        robot.logger.error(err)
      else
        data = JSON.parse body

        robot.logger.info("Dupa debug. data: #{JSON.stringify(data)}")

        if data.messages
          messageText = data.messages[0].text
          textMatch = messageText.match(/kudos (add|dodaj) @?(\S*) (.*)/i)

          if textMatch
            kudosReceiver = textMatch[2].replace(/(<|>|@)/g, '')
            kudosDesc = textMatch[3]
            handlePlusedKudos(kudosReceiver, kudosDesc, reactingUser)

        else
          robot.logger.error('No messages found')

  emoticonToNumber = (emoticonText) ->
    switch emoticonText
      when 'one' then 1
      when 'two' then 2
      when 'three' then 3
      when 'four' then 4
      when 'five' then 5

  handleVotingReaction = (event) ->
    reactingUser = event.user
    questionVoted = emoticonToNumber(event.reaction)

    robot.logger.info(JSON.stringify(event))

    prepareFindMessageRequest(event).get() (err, res, body) ->
      if err
        robot.logger.error(err)
      else
        data = JSON.parse body

        if data.messages
          messageText = data.messages[0].text
          votedQuestionMatch = messageText.match(///^#{questionVoted}\..*\((.*)\)$///i)

          robot.logger.info("Question voted: #{questionVoted}")
          matchedDupaDebug = messageText.match(///^.*Pytanie #{questionVoted}.*///m)
          matchedDupaDebugStrict = messageText.match(///^.*Pytanie 4.*///m)
          robot.logger.info("Dupa debug matchera ze zmienną: #{JSON.stringify(matchedDupaDebug)}")
          robot.logger.info("Dupa debug matchera strict: #{JSON.stringify(matchedDupaDebugStrict)}")

          if votedQuestionMatch
            votedQuestionId = votedQuestionMatch[1]
            robot.logger.info("Voted question #{votedQuestionId}")
          else
            robot.logger.error("Could not match voted question for emoticon #{event.reaction} in #{messageText}")
        else
          robot.logger.error('No messages found')


  reactionsListener = (event) ->
    if (event.reaction == '+1')
      handlePlusOneReaction(event)
    if (['one', 'two', 'three', 'four', 'five'].indexOf(event.reaction) isnt -1)
      handleVotingReaction(event)


  client.on 'reaction_added', reactionsListener

