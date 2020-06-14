# Description:
#   To add and show kudos
#
# Commands:
#   hubot kudos help - pokazuje pomoc dla modułu kudos
#

users = require './common/users'
kudos = require './kudos/kudosDao'

module.exports = (robot) ->
  handlePlusedKudos = (kudosReceiver, kudosDesc, reactingUser) ->
    user = users.getAllUsers(robot).find((u) -> u.id == kudosReceiver || u.name == kudosReceiver)
    robot.logger.info("user #{kudosReceiver}")

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
              robot.logger.error("Error #{errCode}")
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
    reactingUser = event.message.user.id

    request = robot.adapter.client.web.conversations.history
      channel: event.message.item.channel
      latest: event.message.item.ts
      inclusive: true
      limit: 1

    request.then (data) ->
        if data.messages
          messageText = data.messages[0].text
          textMatch = messageText.match(/kudos (add|dodaj) @?(\S*) (.*)/i)

          if textMatch
            kudosReceiver = textMatch[2].replace(/(<|>|@)/g, '')
            kudosDesc = textMatch[3]
            handlePlusedKudos(kudosReceiver, kudosDesc, reactingUser)

        else
          robot.messageRoom event.message.user.id "Upss.... nie znalazłem kudsa :("
          robot.logger.error('No messages found')

  matchingReaction = (msg) ->
    msg.type == 'added' and msg.reaction == '+1' and msg.item.type == 'message'

  robot.hearReaction matchingReaction, handlePlusOneReaction
