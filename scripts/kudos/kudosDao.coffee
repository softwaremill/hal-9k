SECRET = process.env.JANUSZ_BACKEND_SECRET

module.exports.getKudos = (robot, messageResponse, userId) ->
  robot.http("http://misc.sml.cumulushost.eu:9095/kudos/#{userId}")
  .get() (err, res, body) ->
    messageResponse.reply(body)

module.exports.addKudos = (robot, messageResponse, kudoerId, description) ->
  unless SECRET?
    messageResponse.reply("JANUSZ_BACKEND_SECRET env variable not set. Cant add kudos :(")
  else
    data = JSON.stringify({
      userName: messageResponse.message.user.id,
      description: description,
      kudoer: kudoerId
    })

    robot.http("http://misc.sml.cumulushost.eu:9095/kudos")
    .header("Auth-token", SECRET)
    .header("Content-Type", "application/json")
    .post(data) (err, res, body) ->
      jsonBody = JSON.parse(body)

      if jsonBody.status == 500 and jsonBody.exception?.match /.*AuthenticationFailedException/
        messageResponse.reply("Authentication failure. Set env variable JANUSZ_BACKEND_SECRET to proper value")
      else
        messageResponse.reply(if jsonBody.message? then jsonBody.message else body)

module.exports.checkSecret = (robot) ->
  unless SECRET?
    robot.logger.warning "JANUSZ_BACKEND_SECRET env variable not set. Won't be able to add kudos"
