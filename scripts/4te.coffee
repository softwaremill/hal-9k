# Description:
#   Genrates 4th question
#
# Commands:
#   Hubot generates random 4th question

questions = [
  "Najlepsze 4te pytanie do tej pory?",
  "Kogo uważasz za najbardziej hipsterskiego?"
]
module.exports = (robot) ->

  robot.respond /4te\?$/i, (msg) ->
    q = msg.random questions
    msg.send "4te: " + q
