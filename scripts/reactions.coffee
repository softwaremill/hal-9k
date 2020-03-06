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
    robot.logger.info("Question voted: #{questionVoted}")

    prepareFindMessageRequest(event).get() (err, res, body) ->
      if err
        robot.logger.error(err)
      else
        robot.logger.debug("Received body: #{body}")
        data = JSON.parse body

        if data.messages
          messageText = data.messages[0].text

          messageSplitted = messageText.split("\n")
          voted = messageSplitted.map (line) ->
            matcher = line.match(///^#{questionVoted}\..*\((.*)\)$///i)
            if (matcher)
              matcher[1] # return question id
            else
              null

          votedFiltered = voted.filter((value) -> value != null)

          if (votedFiltered.length != 1)
            robot.logger.error("Looks like there is more or less than 1 voted question: #{votedFiltered}")
          else
            votedQuestionId = votedFiltered[0]
            robot.logger.info("User #{reactingUser} voted for question ID: #{votedQuestionId}")


          if votedQuestionId
            robot.logger.info("Voted question #{votedQuestionId}")
            fourthQuestion.vote(robot, reactingUser, votedQuestionId)
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

