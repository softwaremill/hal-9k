# Description:
#   Grammar Corrector for Polish language. It listens on every channel to slap those making mistakes
#
# Commands:
#   hubot ort help - pokazuje pomoc dla modułu ort
#   hubot ort nie <błędne wyrażenie> tylko <poprawne wyrażenie> - dodaje regułę poprawiającą <błędne wyrażenie> na <poprawne wyrażenie>
#   hubot ort usun <błędne wyrażenie> - usuwa regułę poprawiającą <błędne wyrażenie>
#   hubot ort delete <błędne wyrażenie> - j.w.
#

#GRAMMAR_STATS_URL = process.env.HUBOT_GRAMMAR_STATS_APP_URL
#TOKEN = process.env.HUBOT_GRAMMAR_STATS_APP_AUTH_TOKEN
#
#module.exports = (robot) ->
#  robot.hear /.*/, (msg) ->
#    if(msg.message.text.indexOf(' ort ') == -1)
#      request = JSON.stringify(
#        {"userName": msg.message.user.name, "msg": msg.message.text}
#      )
#      robot.http(GRAMMAR_STATS_URL + '/mistakes')
#      .header('Content-Type', 'application/json')
#      .header('Auth-token', TOKEN)
#      .post(request) (err, res, body) ->
#        if !err
#          jsonBody = JSON.parse(body)
#          if jsonBody.mistake
#            msg.send jsonBody.message
#
#  addRule = (res) ->
#    error = res.match[1]
#    correctForm = res.match[2]
#
#    request = JSON.stringify(
#      {"error": error, "correctForm": correctForm}
#    )
#
#    robot.http(GRAMMAR_STATS_URL + '/rules')
#    .header('Content-Type', 'application/json')
#    .header('Auth-token', TOKEN)
#    .post(request) (err, response, body) ->
#      status = response.statusCode
#      if err
#        res.reply "Status #{status}, error = #{err}"
#      else
#        jsonBody = JSON.parse(body)
#        res.reply jsonBody.message
#
#  robot.respond /ort nie @?(.+?) tylko (.+)/i, addRule
#
#  removeRule = (res) ->
#    error = res.match[1]
#
#    request = JSON.stringify(
#      {"error": error}
#    )
#
#    robot.http(GRAMMAR_STATS_URL + '/rules')
#    .header('Content-Type', 'application/json')
#    .header('Auth-token', TOKEN)
#    .delete(request) (err, response, body) ->
#      status = response.statusCode
#      if err
#        res.reply "Status #{status}, error = #{err}"
#      else
#        jsonBody = JSON.parse(body)
#        res.reply jsonBody.message
#
#  robot.respond /ort usun @?(.+)/i, removeRule
#  robot.respond /ort delete @?(.+)/i, removeRule
#
#  robot.respond /ort help/i, (res) ->
#    res.reply("""
#        ort help - wyświetla tę pomoc
#        ort nie <błędne wyrażenie> tylko <poprawne wyrażenie> - dodaje regułę poprawiającą <błędne wyrażenie> na <poprawne wyrażenie>
#        ort usun <błędne wyrażenie> - usuwa regułę poprawiającą <błędne wyrażenie>
#        ort delete <błędne wyrażenie> - j.w.
#      """)
