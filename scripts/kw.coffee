users = require './common/users.coffee'
kw = require './kw/kwDao.coffee'

module.exports = (robot) ->

  forwardResponse = (res) -> 
    (responseBody, response) ->
      code = response.statusCode
      if (code >= 200 && code < 300)
        res.send responseBody
      else
        res.send "Coś poszło nie tak: #{code}: #{responseBody}"

  robot.error (err, res) ->
    robot.logger.error "Unexpected error occured: #{err}"
    if res?
      res.reply "Ups, coś poszło nie tak :( #{err}"

  onError = (err) ->
    robot.logger.error err
    res.reply("Wystąpił błąd: #{err}")

  addCustomPoints = (res) ->
    points = res.match[2].replace(',', '.')
    if points > 0
      userId = res.message.user.id
      desc = res.match[5]
      kw.addCustomPoints robot, userId, points, desc, forwardResponse(res), onError

  addPoints = (res) ->
    activityCode = res.match[3]
    userId = res.message.user.id
    kw.addPoints robot, userId, activityCode, forwardResponse(res), onError

  showMyPoints = (res) ->
    who = users.getUserById(robot, res.message.user.id)
    showPoints(res, who.name)

  showSbPoints = (res) ->
    username = res.match[2]
    showPoints(res, username)

  showPoints = (res, username) ->
    kw.showPoints robot, username, forwardResponse(res), onError

  showAllPoints = (res) ->
    kw.showAllPoints robot, forwardResponse(res), onError

  listActivities = (res) ->
    kw.listActivities robot, forwardResponse(res), onError

  listRanks = (res) ->
    kw.listRanks robot, forwardResponse(res), onError

  withdrawPoints = (res) -> 
    pointsId = res.match[1]
    userId = res.message.user.id
    kw.withdrawPoints robot, userId, pointsId, forwardResponse(res), onError

  printNegativePointsError = (res) ->
    res.send "Synek! Synek! Nie ma takiego dodawania ujemnych punktów, koniec imprezy, dobranoc!\n" +
    "Jeśli potrzebujesz skorygować pomyłkę, użyj `kw cofnij id_punktu`. Więcej informacji w `kw help`"

  printZeroPointsError = (res) ->
    res.send "I na kij ci te 0 punktów, przegrywie? Nudzi ci się? To bloga napisz!"

  printHelp = (res) ->
    help = "Dostępne komendy Króla Wód:\n" +
    "`help kw` - wyświetla tę pomoc\n" +
    "`za co kw` - wyświetla listę promowanych aktywności wraz z ich kodem (kod_aktywności), opisem i punktacją. Tzw. 'taryfikator'\n" +
    "`dodaj kw za <kod_aktywności>` - dodaje punkty za aktywność, zgodnie z 'taryfikatorem'\n" +
    "`dodaj <X.XX> kw za <opis_aktywności>` - dodaje X.XX punktów KW wraz z opisem za customową aktywność\n" +
    "`ile mam kw` - wyświetla listę zdobytych punktów, ich sumę oraz osiągnięty próg KW\n" +
    "`ile kw ma @<ktoś>` - wyświetla listę punktów zdobytych przez @<ktoś>, ich sumę oraz osiągnięty próg KW\n" +
    "`ranking kw` - wyświetla firmowy ranking wraz z progami\n" +
    "`progi kw` - wyświetla listę progów wraz z wymaganą liczbą punków\n" +
    "`odejmij kw <id_punktu>` - usuwa Twój KW o id=id_punktu. Identyfikator zwracany jest przez komendę `kw ile mam`\n"
    
    res.send help

  robot.respond /help kw/i, printHelp
  robot.respond /pomoc kw/i, printHelp
  robot.respond /kw/i, printHelp

  robot.respond /(dodaj|daj|dej) \+?([0-9]+[\.,]?[0-9]{0,2})([ ]?(pkt|punkt|punkty|punkta))? kw za (.*)/i, addCustomPoints
  robot.respond /(dodaj|daj|dej) -([0-9]+[\.,]?[0-9]{0,2})([ ]?(pkt|punkt|punkty|punkta))? kw/i, printNegativePointsError
  robot.respond /(dodaj|daj|dej) -?(0+[\.,]?[0]{0,2})([ ]?(pkt|punkt|punkty|punkta))? kw/i, printZeroPointsError

  robot.respond /(dodaj|daj|dej) kw (za )?([a-z][^\s]*)/i, addPoints

  robot.respond /ile (ja )?mam (pkt |punktów )?kw[\?]?/i, showMyPoints

  robot.respond /ile (pkt |punktów )?kw ma @([^\s]+)[\?]?/i, showSbPoints
  
  robot.respond /ranking kw$/i, showAllPoints

  robot.respond /za co kw$/i, listActivities

  robot.respond /progi kw$/i, listRanks

  robot.respond /cofnij kw ([1-9][0-9]*)/i, withdrawPoints
  robot.respond /odejmij kw ([1-9][0-9]*)/i, withdrawPoints
