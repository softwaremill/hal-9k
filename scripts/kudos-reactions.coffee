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

    kudos.isKudos(
      robot,
      (body) ->
        try
          json = JSON.parse(body)
          robot.logger.info "Response #{body}"
          if json.message == "true"
            robot.logger.info "Message #{res.message.item.ts} is Kudos"
            kudos.addPlusOneByMessageId(robot, onSuccess, onError, res.message.user.id, res.message.item.ts)
          else
            robot.logger.info "Message #{res.message.item.ts} is not a Kudos"
        catch error
          robot.logger.error error
      ,
      (err, errCode) ->
          robot.logger.error "Error: #{err} (#{errCode})"
      ,
      res.message.item.ts
    )

  matchingReaction = (msg) ->
    robot.logger.info "Got message type #{msg.type} with reaction #{msg.reaction}"
    msg.type == 'added' and msg.item.type == 'message' and (msg.reaction.startsWith('+1') or msg.reaction == 'white_check_mark')

  robot.hearReaction matchingReaction, handlePlusOneReaction
