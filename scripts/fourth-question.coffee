# Description:
#   Zapisuje albo zwraca czwarte pytanie
#
# Commands:
#   hubot dodaj czwarte - zapisuje czwarte pytanie w kolejce. e.g. janusz dodaj czwarte Jakie opony na zimę?
#   hubot add 4te - zapisuje czwarte pytanie w kolejce
#   hubot dodaj czwarte - zapisuje czwarte pytanie w kolejce
#   hubot jakie czwarte - zwraca czwarte pytanie na dzisiaj
#   hubot daj czwarte - zwraca czwarte pytanie na dzisiaj
#   hubot dej 4te - zwraca czwarte pytanie na dzisiaj
#   hubot to jakie dziś czwarte - zwraca czwarte pytanie na dzisiaj
#   hubot jakie dziś czwarte - zwraca czwarte pytanie na dzisiaj
#   hubot poproszę o czwarte pytanie - zwraca czwarte pytanie na dzisiaj

fourthQuestion = require './fourth_question/FourthQuestionDao'
CronJob = require('cron').CronJob
timeZone = 'Europe/Warsaw'
{WebClient} = require "@slack/client"

module.exports = (robot) ->

  # temporary solution to use a different token with proper scopes
  webClient = new WebClient(process.env.HUBOT_SLACK_OAUTH_TOKEN)

  FourthQuestionVotingEndSentence = "Zagłosuj przez wybranie odpowiedniej reakcji"

  EmojiToNumberOfVotedQuestionMap = [
    {
      name: "orange_diamond",
      questionNumber: 1
    },
    {
      name: "large_blue_circle",
      questionNumber: 2
    },
    {
      name: "red_triangle",
      questionNumber: 3
    },
    {
      name: "green_square",
      questionNumber: 4
    },
    {
      name: "purple_heart",
      questionNumber: 5
    },
  ]

  getQuestionNumberForEmoji = (emoji) ->
    filtered = EmojiToNumberOfVotedQuestionMap.filter (x) -> x.name == emoji
    return filtered[0].questionNumber

  getEmojiForQuestionNumber = (qNumber) ->
    filtered = EmojiToNumberOfVotedQuestionMap.filter (x) -> x.questionNumber == qNumber
    return filtered[0].name

  add4thQ = (res) ->
    res.finish()
    _4thQuestion = res.match[1]

    successHandler = (successBody) ->
      robot.logger.debug("Response : #{successBody}")
      jsonBody = JSON.parse(successBody)
      res.reply(jsonBody.message)

    errorHandler =
      (err, errCode) -> res.reply("Error #{errCode}")

    res.reply("Przyjąłem, ładowacze klas ruszają do pracy...")
    fourthQuestion.add(robot, successHandler, errorHandler, res.message.user.name, _4thQuestion)


  get4thQ = (res) ->
    res.finish()

    responseSender = (text) ->
      res.reply(text)

    errorHandler =
      (err, errCode) ->
        res.reply("Error #{errCode}: #{err}")

    res.reply("Proszę o cierpliwość, szukam ...")
    fourthQuestion.get(robot, successHandlerFactory(responseSender), errorHandler)


  displayQuestionOnChrumChannel = (suppressPredefined) ->
    return ->
      chrumRoomSender = (text) ->
        robot.messageRoom "#chrum", text

      errorHandler =
        (err, errCode) ->
          robot.logger.error("Couldn't display election. Error: #{err}. ErrorCode: #{errCode}")

      fourthQuestion.get(robot, successHandlerFactory(chrumRoomSender, true, suppressPredefined), errorHandler)


  successHandlerFactory = (responseSender, suppressMissing, suppressPredefined) ->
    return (successBody, httpResponse) ->
      robot.logger.info("Response : #{successBody}")
      jsonBody = JSON.parse(successBody)

      if (httpResponse.statusCode == 404)
        if(!suppressMissing)
          responseSender("Brak pytania na dzis: *#{jsonBody.message}*")
        return

      if(jsonBody.predefinedQuestion)
        if(!suppressPredefined)
          responseSender("Czwarte pytanie na dzisiaj: *#{jsonBody.predefinedQuestion}*")
      else
        election = jsonBody.election
        switch election.status
          when "IN_PROGRESS"
            votingText = "Kandydaci na 4te pytanie -- [GŁOSOWANIE #{election.electionDate}] -- Trwa od *7:00* do *9:50* \n"
            for candidate, i in election.candidates
              votingText += ":#{getEmojiForQuestionNumber(i + 1)}:  #{candidate.questionContent}\n"

            votingText += FourthQuestionVotingEndSentence
            responseSender(votingText)
          when "COMPLETED"
            responseSender("Czwarte pytanie na dzisiaj: *#{election.winnerQuestionContent}* (autor: #{election.authorOfWinningQuestion})")
          else
            responseSender("Nieznany status głosowania :/ #{election.status}")

  addReaction = (emojiName, event) ->
    robot.adapter.client.web.reactions.add(
      emojiName,
      {
        channel: event.channel,
        timestamp: event.ts
      }
    )

  # Display a voting message just after backend created an election with random questions
  new CronJob('0 0 7 * * *', displayQuestionOnChrumChannel(true), null, true, timeZone)

  # Display a winner question 10 minutes before chrum meeting
  new CronJob('30 50 9 * * *', displayQuestionOnChrumChannel(), null, true, timeZone)


  robot.respond /4te add (.*)/i, add4thQ
  robot.respond /add 4te (.*)/i, add4thQ
  robot.respond /czwarte add (.*)/i, add4thQ
  robot.respond /add czwarte (.*)/i, add4thQ
  robot.respond /4te dodaj (.*)/i, add4thQ
  robot.respond /dodaj 4te (.*)/i, add4thQ
  robot.respond /czwarte dodaj (.*)/i, add4thQ
  robot.respond /dodaj czwarte (.*)/i, add4thQ

  robot.respond /daj 4te/i, get4thQ
  robot.respond /daj czwarte/i, get4thQ
  robot.respond /dej 4te/i, get4thQ
  robot.respond /dej czwarte/i, get4thQ
  robot.respond /jakie czwarte/i, get4thQ
  robot.respond /jakie 4te/i, get4thQ
  robot.respond /to jakie dziś czwarte/i, get4thQ
  robot.respond /jakie dziś czwarte/i, get4thQ
  robot.respond /poproszę o czwarte pytanie/i, get4thQ

  robot.respond /(wywal|kick|drop) (czwarte|4te|4|4th) "(.*)"/i, (res) ->
    robot.logger.info "Dropping 4th question '#{res.match[2]}' by #{res.message.user.name}"

    onSuccess = (body, response) ->
      robot.logger.info("User #{dropUser} dropped question #{droppedQuestion}. Status: #{response.statusCode}. Body: #{body}")
      res.send "I gotowe :wapno:"

    onError = (err, errCode) ->
      robot.logger.error("Error dropping question #{droppedQuestion} by user #{dropUser}: (#{errCode}) #{err}")
      res.reply "No i: #{err} :shit:"

    fourthQuestion.drop robot, onSuccess, onError, res.message.user.name, res.match[2]

  robot.adapter.client.rtm.on 'message', (event) ->
    if (event.bot_id != undefined && event.text.match(///#{FourthQuestionVotingEndSentence}///i))
      for item in EmojiToNumberOfVotedQuestionMap
        addReaction(item.name, event)

  handleVotingReaction = (event) ->
    reactingUser = event.user
    questionVoted = getQuestionNumberForEmoji(event.reaction)
    robot.logger.info("Question voted: #{questionVoted}")

    webClient.conversations.history
      channel: event.item.channel
      latest: event.item.ts
      inclusive: true
      limit: 1
    .then (data) ->
      robot.logger.info data
      if data.messages
        messageText = data.messages[0].text
        firstLine = messageText.split("\n")[0]

        if firstLine.includes("GŁOSOWANIE")
          electionDate = firstLine.match(/20\d\d-\d\d-\d\d/)[0]
          robot.logger.info("User #{reactingUser} voted for question ID: #{questionVoted}. Election date: #{electionDate}")
          fourthQuestion.vote(robot, reactingUser, questionVoted, electionDate)
        else
          robot.logger.error("Voted message is not a poll message: #{messageText}")
      else
        robot.logger.error("No messages found in #{data}")
    .catch (err) ->
      robot.logger.error err
      robot.messageRoom event.user.id, "Nie mogłem dodać Twojego głosu na 4te bo: #{err}"

  reactionsListener = (event) ->
    if ((EmojiToNumberOfVotedQuestionMap.map (it) -> it.name ).indexOf(event.reaction) isnt -1)
      handleVotingReaction(event)

  robot.adapter.client.rtm.on 'reaction_added', reactionsListener