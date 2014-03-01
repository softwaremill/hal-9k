# Description:
#   Genrates 4th question
#
# Commands:
#   Hubot says good bye on out

questions = [
  "Najlepsze 4te pytanie do tej pory?",
  "Kogo uważasz za najbardziej histerskiego?"
]
module.exports = (robot) ->
  robot.response /^4te\?$/i, (msg) ->
    q = msg.random questions

    msg.send q
