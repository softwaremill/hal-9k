# Description:
#   Grammar Nazi for Polish language. It listens on every channel to slap those making mistakes
#

module.exports = (robot) ->
  robot.hear prepareGrammarNaziDetectingRegEx(), (msg) ->
    author = msg.message.user.name
    grammarFailure = msg.match[1]
    exclamationSentence = msg.random messages
    msg.send 'Grammar Nazi: pisze się *' + errors[grammarFailure.toLowerCase().trim()] + '*, @' + author + ' ' + exclamationSentence + '!'

prepareGrammarNaziDetectingRegEx = ->
  errorWords = []
  for k, v of errors
    errorWords.push k

  joinedErrors = errorWords.join('|')
  new RegExp '.*(' + joinedErrors + ').*', 'i'

errors =
  'wziąść'  : 'wziąć'
  'wziasc'  : 'wziąć'
  'wziaść'  : 'wziąć'
  'pokarze' : 'pokażę'
  'pokarzę' : 'pokażę'
  'żądzić'  : 'rządzić'
  'żadzić'  : 'rządzić'
  'żadzic'  : 'rządzić'
  'ządzic'  : 'rządzić'
  'rządać'  : 'żądać'
  'rzadac'  : 'żądać'
  'rządac'  : 'żądać'
  'pojedyńcz'  : 'pojedynczy'
  'z tąd'  : 'stąd'
  'z tad'  : 'stąd'
  'z tamtąd': 'stamtąd'
  'z tamtad': 'stamtąd'
  'wogóle': 'w ogóle'
  'wogole': 'w ogóle'
  'wogule': 'w ogóle'
  'z przed': 'sprzed'
  'napewno': 'na pewno'
  'conamniej': 'co najmniej'
  'poprostu': 'po prostu'
  'na prawdę' : 'naprawdę'
  'na prawde' : 'naprawdę'
  'nie prawda': 'nieprawda'
  'poprostu': 'po prostu'
  'nie prawda': 'nieprawda'
  'na przeciwko': 'naprzeciwko'
  'umią'  : 'umieją'
  'umia'  : 'umieją'
  'rozumią'  : 'rozumieją'
  'rozumia'  : 'rozumieją'
  'przekonywujący': 'przekonujący'
  'przekonywujacy': 'przekonujący'
  'tylni': 'tylny'
  'poszłem': 'poszedłem'
  'poszlem': 'poszedłem'
  'orginalny': 'oryginalny'
  'wszechczasów': 'wszech czasów'
  'wszechczasow': 'wszech czasów'
  'oddziaływuje': 'oddziałuje'
  'oddzialywuje': 'oddziałuje'
  'spowrotem': 'z powrotem'
  'możnaby': 'można by'
  'moznaby': 'można by'
  'na codzień': 'na co dzień'
  'na codzien': 'na co dzień'
  'mogło by': 'mogłoby'
  'moglo by': 'mogłoby'
  'szyji': 'szyi'
  'wgłąb': 'w włąb'
  'wglab': 'w włąb'
  'nielada': 'nie lada'
  'nadzieji': 'nadziei'
  'swetr': 'sweter'

messages = [
  'no kurde',
  'do diaska',
  'nieuku ty',
  'ehh, szkoda słów',
  'czy Ty sie w koncu tego nauczysz?',
  'znany ekspercie od wszystkiego',
  'chamie bez szkoły',
  'bitch please',
  'ja pitolę',
  'ile razy mam powtarzać?',
  'z tobą jak z małym dzieckiem'
]
