# Description:
#   Grammar Corrector for Polish language. It listens on every channel to slap those making mistakes
#

GRAMMAR_STATS_URL = process.env.HUBOT_GRAMMAR_STATS_APP_URL
TOKEN = process.env.HUBOT_GRAMMAR_STATS_APP_AUTH_TOKEN

module.exports = (robot) ->
  robot.hear /.*/, (msg) ->
    request = JSON.stringify(
      {"userName": msg.message.user.name, "msg": msg.message.text}
    )

    robot.http(GRAMMAR_STATS_URL + '/mistakes')
    .header('Content-Type', 'application/json')
    .header('Auth-token', TOKEN)
    .post(request) (err, res, body) ->
      if !err
        jsonBody = JSON.parse(body)
        if jsonBody.mistake
          msg.send jsonBody.message