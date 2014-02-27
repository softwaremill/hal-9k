# Description:
#   Says bye
#
# Commands:
#   Hubot says good bye on out

byes = [
  "See you tomorrow %!",
  "Goodbye %!",
  "Have a nice evening %!",
  "Bye %, I'll be here all night long!",
  "Cya %! I'll keep eye on everything!"
]
weekends = [
  "Have a nice weekend %",
  "Cya on monday %",
  "Bye %! The sun will shine on monday too!",
  "Goodbye, rest and relax %! New week starts on monday!",
  "Bye %! Weekend, yeah!!!"
]
module.exports = (robot) ->
  robot.hear /(out|bye|pa|nara|dozo)/i, (msg) ->
    bye = msg.random byes

    if new Date().getDay() == 5
      bye = msg.random weekends

    msg.send bye.replace "%", msg.message.user.name
