# Description:
#   Introduce himself
#
# Commands:
#   about|o sobie|introduce yourself - short info about myself

module.exports = (robot) ->

  robot.respond /(about|o sobie|introduce yourself)$/i, (msg) ->
    msg.send "Od czego by tu zacząć... no tak jestem wybitnie uzdolniony" +
             " i znam się na wszystkim, mogę odpowiedzieć na każde pytanie." +
             " Masz jakieś?"
