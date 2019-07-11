# Description:
#   Introduce himself
#
# Commands:
#   hubot about|o sobie|introduce yourself - krótko o samym sobie

module.exports = (robot) ->

  fochMsg = 'No co? Każdy może się pomylić :foch:'
  motylaNogaMsg ='Poczytaj sobie https://www.youtube.com/watch?v=OGXfPVdmosY'
  sorryMsg = 'Przepraszam, ja też miewam gorsze dni :('

  robot.respond /(about|o sobie|introduce yourself)$/i, (msg) ->
    msg.send "Od czego by tu zacząć... no tak jestem wybitnie uzdolniony" +
             " i znam się na wszystkim, mogę odpowiedzieć na każde pytanie." +
             " Masz jakieś?"

  robot.respond /kurwa$/i, (msg) ->
    msg.send fochMsg

  robot.hear /.*(kurwa).*(\s)(@?janusz).*/i, (msg) ->
    msg.send fochMsg

  robot.respond /motyla noga(\s?).*/i, (msg) ->
    msg.send motylaNogaMsg

  robot.hear /.*(motyla noga).*(\s)(@?janusz).*/i, (msg) ->
    msg.send motylaNogaMsg

  robot.respond /ja pierdol(e|ę)(\s?).*/i, (msg) ->
    msg.send sorryMsg

  robot.hear /.*(ja pierdol)(e|ę).*(\s)(@?janusz).*/i, (msg) ->
    msg.send sorryMsg

  robot.hear /.*(zatrudnia)(ć|c|my)\??(\s).*/i, (msg) ->
    msg.send "Ciekawe co powie Nerdal ... https://www.screencast.com/t/N4cbbaZlCvW"

  robot.respond /bluejeans|bj/i, (msg) ->
    if msg.message.room == 'topdown' || msg.message.room == '#topdown'
      msg.respond 'https://bluejeans.com/4955736566'
    msg.finish()
