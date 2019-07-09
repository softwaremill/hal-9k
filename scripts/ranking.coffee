# Description:
#   Ranking of SML team
#
# Commands:
#   hubot ranking - shows ranking of SML team

PTS_PER_HIRING_ITEM = 0.25

zlib = require('zlib');
CronJob = require('cron').CronJob
pointsModifier = require('./ranking-points-modifier.coffee')
hiringModifier = require('./ranking-hiring-activities.coffee')

tz = 'Europe/Warsaw'

weights =
  "blog-posts": 1
  "conference-presentations": 1
  "meetup-presentations": 1

combineData = (a, b) ->
  data = Object.assign({}, a)
  
  Object.keys(b).forEach (user) ->
    data[user] = data[user] || {}

    Object.keys(b[user]).forEach (score) ->
      data[user][score] = (data[user][score] || 0) + b[user][score]

  data

addSums = (data) ->
  withSums = Object.assign({}, data)
  
  Object.keys(withSums).forEach (user) ->
    withSums[user].sum = 0
    Object.keys(withSums[user]).forEach (score) ->
      withSums[user].sum += withSums[user][score] * weights[score] if !!weights[score]

  withSums

yearStats = (data, year) ->
  addSums(
    Object.keys(data[year]).reduce(
      (result, month) ->
        combineData(result, data[year][month])
      {}
    )
  )

mergePointsModifierWithCurrentYearStats = (yearStats) ->
  withPointsModifier = Object.assign({}, yearStats)
  Object.keys(pointsModifier).forEach (user) ->
    if !(user of withPointsModifier)
      withPointsModifier[user] = sum: 0
    withPointsModifier[user]['modifier'] = pointsModifier[user] || 0
    withPointsModifier[user].sum += pointsModifier[user]

  withPointsModifier

mergeHiringModifierWithCurrentYearStats = (yearStats) ->
  withHiringModifier = Object.assign({}, yearStats)
  Object.keys(hiringModifier).forEach (user) ->
    if !(user of withHiringModifier)
      withHiringModifier[user] = sum: 0
    hiringPoints = (hiringModifier[user]['cr'] + hiringModifier[user]['tech']) * PTS_PER_HIRING_ITEM || 0
    withHiringModifier[user]['hiring'] = hiringPoints
    withHiringModifier[user].sum += hiringPoints

  withHiringModifier

monthStats = (data, year, month) ->
  addSums(data[year][month])

getLabel = (points) ->
  if points >= 16
    return "_sum tak zwany olimpijczyk_"
  else if points >= 8
    return "_szczupak_"
  else if points >= 4
    return "_leszcz_"
  else if points >= 2
    return "_karaś_"
  else
    return ""

prepareMessage = (stats) ->
  sortedUsers = Object.keys(stats).sort (a, b) ->
    stats[b].sum - stats[a].sum

  lp = 0
  lastSum = 0;
  key = 0

  attachments = []

  for user in sortedUsers
    key++
    if lastSum != stats[user].sum
      lp = key
      lastSum = stats[user].sum

    if stats[user].sum == 0
      break

    label = getLabel(stats[user].sum)
    sum = stats[user].sum
    blogPosts = (stats[user]['blog-posts'] || 0)
    presentations = (stats[user]['conference-presentations'] || 0)
    meetups = (stats[user]['meetup-presentations'] || 0)
    modifier = (stats[user]['modifier'] || 0)
    hiring = (stats[user]['hiring'] || 0)

    attachments.push
      text: "#{lp}. *#{user}* #{label}: (`#{sum}`) => [`#{blogPosts}`/`#{presentations}`/`#{meetups}`/`#{hiring}`/`#{modifier}`]",
      mrkdwn_in: [
        "text"
      ]

  attachments

sectionHeader = (prefix) ->
  "#{prefix} ranking <https://kiwi.softwaremill.com/pages/viewpage.action?pageId=35719603|króla wód> - (Suma) => [Blogi / Konferencyjki / Meetupy / Hiring / <https://kiwi.softwaremill.com/pages/viewpage.action?pageId=35719603&focusedCommentId=36929932#comment-36929932|Inne> ]:"

module.exports = (robot) ->

  showRanking = ->
    robot.logger.info 'emitting ranking:show to #_wazne_'
    robot.emit 'ranking:show', '#_wazne_'

  showDebugRanking = ->
    robot.logger.info 'emitting ranking:show to #mainframe'
    robot.emit 'ranking:show', 'mainframe'

  new CronJob('0 0 9 28 * *', showRanking, null, true, tz)
  # new CronJob('*/15 * * * * *', showDebugRanking, null, true, tz)

  robot.respond /RANKING$/i, (msg) ->
    robot.emit 'ranking:show', msg.message.room

  robot.on 'ranking:show', (room) ->
    onError = (err) ->
      robot.messageRoom room, "Nie mogę pobrać danych do rankingu: #{err}"

    onSuccess = (data) ->
      date = new Date()
      year = date.getFullYear().toString();
      month = (date.getMonth() + 1).toString();

      yearStatsWithPointsModifier = mergePointsModifierWithCurrentYearStats(yearStats(data, year))
      yearStatsWithPointsAndHiringModifier = mergeHiringModifierWithCurrentYearStats(yearStatsWithPointsModifier)
      yearRanking = prepareMessage(yearStatsWithPointsAndHiringModifier)
      monthRanking = prepareMessage(monthStats(data, year, month))

      response = undefined
      if yearRanking.length > 0
        response =
          text: sectionHeader('Roczny')
          attachments: yearRanking
          username: robot.name
          as_user: true
      else
        response = "Ups... nie ma rocznego rankingu!"

      robot.logger.info JSON.stringify(response)
      robot.messageRoom room, response

      if monthRanking.length > 0
        response =
          text: sectionHeader('Miesięczny')
          attachments: monthRanking
          username: robot.name
          as_user: true
      else
        response = "Ups... nie ma miesięcznego rankingu!"

      robot.logger.info JSON.stringify(response)
      robot.messageRoom room, response

    robot.http("https://s3.eu-central-1.amazonaws.com/softwaremill-strona-2016/ranking.json")
      .get( (err, req)->
        data = ''
        req.addListener "response", (res) ->
          output = res
          
          if res.headers['content-encoding'] is 'gzip'
            output = zlib.createGunzip()
            res.pipe(output)

          output.on 'error', (err) ->
            onError err

          output.on 'data', (d) ->
            data += d.toString('utf-8')

          output.on 'end', () ->
            parsedData = JSON.parse(data)
            onSuccess parsedData
      )()
