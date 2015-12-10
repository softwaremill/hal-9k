# Description:
#   Genrates 4th question
#
# Commands:
#   hubot 4te - Generuje 4te pytanie z listy

questions = [
  "Najlepsze 4te pytanie do tej pory?",
  "Kogo uważasz za najbardziej hipsterskiego?",
  "Twoje Boje: z jaką pokusą często walczysz?",
  "Co lubisz w Polsce?",
  "Jak spędziłeś weekend?",
  "To Se Ne Vrati: Za czym, co już nie wróci, tęsknisz?",
  "Jakie (jeżeli wogóle) paliłeś pierwsze papierosy?",
  "Za jakim ciałem tęsknisz? (interpretacja dowolna)",
  "Grajki. Na jakich instrumentach graliście lub gracie?",
  "Jaka nowa technologia/aplikacja sprawiła, że złapałeś/łaś się za głowę?"
]
module.exports = (robot) ->

  robot.respond /4te\?$/i, (msg) ->
    q = msg.random questions
    msg.send "#4te: " + q
