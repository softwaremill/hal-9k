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

  robot.respond /bluejeans/i, (res) ->
    res.send 'Link do BJ https://bluejeans.com/4955736566'

  robot.respond /(td|topdown) (standup|meeting|zoom)/i, (res) ->
    res.send 'Spotkanie jest tutaj https://zoom.us/j/2716999780'
