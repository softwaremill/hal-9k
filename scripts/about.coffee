# Description:
#   Introduce himself
#
# Commands:
#   hubot about|o sobie|introduce yourself - krótko o samym sobie

module.exports = (robot) ->

  robot.respond /(about|o sobie|introduce yourself)$/i, (msg) ->
    msg.send "Od czego by tu zacząć... no tak jestem wybitnie uzdolniony" +
             " i znam się na wszystkim, mogę odpowiedzieć na każde pytanie." +
             " Masz jakieś?"

  robot.respond /kurwa$/i, (msg) ->
    msg.send 'No co? Każdy może się pomylić :foch:'