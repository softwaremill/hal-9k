# Description:
#   Grammar Corrector for Polish language. It listens on every channel to slap those making mistakes
#

module.exports = (robot) ->
  robot.hear /.*/, (msg) ->
    msgWithoutPolishChars = replacePolishChars(msg.message.text)
    regex = prepareGrammarNaziDetectingRegEx()
    matches = regex.exec(msgWithoutPolishChars)
    if (matches != null )
      author = msg.message.user.name
      exclamationSentence = msg.random messages
      msg.send  '@' + author + ', ' + exclamationSentence + '! Poprawna forma to *' + errors[matches[0].trim()] + '*'

replacePolishChars = (text) ->
    text.toLowerCase()
      .replace('ą', 'a')
      .replace('ć', 'c')
      .replace('ę', 'e')
      .replace('ł', 'l')
      .replace('ń', 'n')
      .replace('ó', 'o')
      .replace('ś', 's')
      .replace('ż', 'z')
      .replace('ź', 'z')


prepareGrammarNaziDetectingRegEx = ->
  errorWords = []
  for k, v of errors
    errorWords.push k

  joinedErrors = errorWords.join('|')
  new RegExp '(^|\\s)(' + joinedErrors + ')($|\\s)', 'i'

errors =
  'wziasc'  : 'wziąć'
  'pokarze' : 'pokażę'
  'zadzic'  : 'rządzić'
  'rzadac'  : 'żądać'
  'z tad'  : 'stąd'
  'z tamtad': 'stamtąd'
  'wogole': 'w ogóle'
  'w ogule': 'w ogóle'
  'z przed': 'sprzed'
  'napewno': 'na pewno'
  'conamniej': 'co najmniej'
  'poprostu': 'po prostu'
  'na prawdę' : 'naprawdę'
  'nie prawda': 'nieprawda'
  'poprostu': 'po prostu'
  'nie prawda': 'nieprawda'
  'na przeciwko': 'naprzeciwko'
  'umia'  : 'umieją'
  'rozumia'  : 'rozumieją'
  'przekonywujacy': 'przekonujący'
  'tylni': 'tylny'
  'poszlem': 'poszedłem'
  'przyszlem': 'przyszedłem'
  'wyszlem': 'wyszedłem'
  'rzyglem': 'rzygnąłem'
  'rzyglam': 'rzygnęłam'
  'zyglem': 'rzygnąłem'
  'zyglam': 'rzygnęłam'
  'orginalny': 'oryginalny'
  'wszechczasow': 'wszech czasów'
  'oddzialywuje': 'oddziałuje'
  'spowrotem': 'z powrotem'
  'moznaby': 'można by'
  'trzebaby': 'trzeba by'
  'na codzien': 'na co dzień'
  'moglo by': 'mogłoby'
  'szyji': 'szyi'
  'wglab': 'w głąb'
  'nielada': 'nie lada'
  'nadzieji': 'nadziei'
  'swetr': 'sweter'
  'huj': 'chuj'
  'hoj': 'chuj'
  'grzegrzolka': 'gżegżółka'
  'do prawdy': 'doprawdy'
  'hamstwo': 'chamstwo'
  'hamstwa': 'chamstwa'


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
  'z tobą jak z małym dzieckiem',
  'chyba egzystujesz w intelektualnym brodziku',
  'chyba pracowałeś w Nabino',
  'no to prezent na urodziny ustalony, od SML dostaniesz słownik'
]