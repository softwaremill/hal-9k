# Description:
#   Says bye
#
# Commands:
#   Hubot says good bye on out

byes = [
  "See you tomorrow, %!",
  "Goodbye, %!",
  "Have a nice evening, %!",
]
weekends = [
  "Have a nice weekend, %",
]
module.exports = (robot) ->
  robot.hear /(out|bye)/i, (msg) ->
    bye = msg.random byes

    if new Date().getDay() == 5
      bye = msg.random weekends

    msg.send bye.replace "%", msg.message.user.name
