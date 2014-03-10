# Description:
#   Genrates 4th question
#
# Commands:
#   Hubot generates random 4th question

questions = [
  "Najlepsze 4te pytanie do tej pory?",
  "Kogo uważasz za najbardziej hipsterskiego?",
  "Twoje Boje: z jaką pokusą często walczysz?",
  "Co lubisz w Polsce?",
  "Jak spędziłeś weekend?"
]
module.exports = (robot) ->

  robot.respond /4te\?$/i, (msg) ->
    q = msg.random questions
    msg.send "#4te: " + q
