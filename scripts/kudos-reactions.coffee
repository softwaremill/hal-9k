# Description:
#   To add and show kudos
#
# Commands:
#   hubot kudos help - pokazuje pomoc dla modułu kudos
#

kudos = require './kudos/kudosDao'

module.exports = (robot) ->

  handlePlusOneReaction = (res) ->
    onSuccess = (body) ->
      robot.logger.info "Response from backend: #{body}"
      jsonBody = body
      try
        jsonBody = JSON.parse(body)
      catch error
        robot.logger.error "Cannot parse #{body} as JSON, got error: #{error}"

      if jsonBody.error
        robot.logger.error jsonBody.message
        robot.messageRoom res.message.user.id, "Coś poszło nie tak: #{jsonBody.message}"
      else
        if jsonBody.id
          robot.messageRoom res.message.user.id, "Ok, kudos dodany. ID=#{jsonBody.id}"
        else if jsonBody.message
          robot.messageRoom res.message.user.id, "Ok, kudos dodany. Status=#{jsonBody.message}"
        else
          robot.messageRoom res.message.user.id, "Ok, kudos dodany. Status=#{body}"

    onError =
      (err, errCode) ->
        robot.messageRoom res.message.user.id, "Upss... coś poszło nie tak przy dodawniu :+1: do kudosa: (#{errCode}) #{error}"

    kudos.addPlusOneByMessageId(robot, onSuccess, onError, res.message.user.id, res.message.item.ts)

  matchingReaction = (msg) ->
    msg.type == 'added' and msg.reaction.startsWith('+1') and msg.item.type == 'message'

  robot.hearReaction matchingReaction, handlePlusOneReaction
