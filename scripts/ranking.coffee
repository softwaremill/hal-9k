# Description:
#   Ranking of SML team
#
# Commands:
#   hubot ranking - shows ranking of SML team

zlib = require('zlib');

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

  attachments = []

  for user in sortedUsers
    if lastSum != stats[user].sum
      lp++
      lastSum = stats[user].sum

    attachments.push
      text: "#{lp}. *#{user}* #{getLabel(stats[user].sum)} (`#{stats[user].sum}`) [`#{(stats[user]['blog-posts'] || 0)}`/`#{(stats[user]['conference-presentations'] || 0)}`/`#{(stats[user]['meetup-presentations'] || 0)}]`",
      mrkdwn_in: [
        "text"
      ]

  attachments

module.exports = (robot) ->
  robot.respond /RANKING$/i, (msg) ->
    onError = (err) ->
      msg.reply("Błąd: #{err}")

    onSuccess = (data) ->
      date = new Date()
      year = date.getFullYear().toString();
      month = (date.getMonth() + 1).toString();

      yearRanking = prepareMessage(yearStats(data, year))
      monthRanking = prepareMessage(monthStats(data, year, month))

      response = undefined
      if yearRanking.length > 0
        response =
          text: 'Roczny ranking <https://kiwi.softwaremill.com/pages/viewpage.action?pageId=35719603|króla wód> - (Suma) [Blogi / Konferencyjki / Meetupy]:'
          attachments: yearRanking
          username: robot.name
          as_user: true
      else
        response = "Ups... nie ma rocznego rankingu!"

      robot.logger.info JSON.stringify(response)
      msg.send response;

      if monthRanking.length > 0
        response =
          text: 'Miesięczny ranking <https://kiwi.softwaremill.com/pages/viewpage.action?pageId=35719603|króla wód> - (Suma) [Blogi / Konferencyjki / Meetupy]:'
          attachments: monthRanking
          username: robot.name
          as_user: true
      else
        response = "Ups... nie ma miesięcznego rankingu!"

      robot.logger.info JSON.stringify(response)
      msg.send response, ""

    msg.http("https://softwaremill.com/ranking.json")
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
