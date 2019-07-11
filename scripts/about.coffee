# Description:
#   Introduce himself
#
# Commands:
#   hubot about|o sobie|introduce yourself - krótko o samym sobie

module.exports = (robot) ->

  fochMsg = 'No co? Każdy może się pomylić :foch:'
  motylaNogaMsg ='Poczytaj sobie https://www.youtube.com/watch?v=OGXfPVdmosY'
  sorryMsg = 'Przepraszam, ja też miewam gorsze dni :('

  robot.respond /(about|o sobie|introduce yourself)$/i, (res) ->
    res.send "Od czego by tu zacząć... no tak jestem wybitnie uzdolniony" +
             " i znam się na wszystkim, mogę odpowiedzieć na każde pytanie." +
             " Masz jakieś?"

  robot.respond /kurwa$/i, (res) ->
    res.send fochMsg

  robot.hear /.*(kurwa).*(\s)(@?janusz).*/i, (res) ->
    res.send fochMsg

  robot.respond /motyla noga(\s?).*/i, (res) ->
    res.send motylaNogaMsg

  robot.hear /.*(motyla noga).*(\s)(@?janusz).*/i, (res) ->
    res.send motylaNogaMsg

  robot.respond /ja pierdol(e|ę)(\s?).*/i, (res) ->
    res.send sorryMsg

  robot.hear /.*(ja pierdol)(e|ę).*(\s)(@?janusz).*/i, (res) ->
    res.send sorryMsg

  robot.hear /.*(zatrudnia)(ć|c|my)\??(\s?).*/i, (res) ->
    res.send "Ciekawe co powie Nerdal ... https://www.screencast.com/t/N4cbbaZlCvW"

  robot.respond /bluejeans|bj/i, (res) ->
    robot.logger.info JSON.stringify(robot.adapter.channelMapping)
    robot.logger.info JSON.stringify(robot.adapter)

    robot.logger.info "Checking what room I'm in #{JSON.stringify(res.message)}"
    if res.message.room == 'topdown' || res.message.room == '#topdown'
      res.respond 'https://bluejeans.com/4955736566'

    res.finish()
