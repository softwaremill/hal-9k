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

prepareMessage = (stats) ->
  sortedUsers = Object.keys(stats).sort (a, b) ->
    stats[b].sum - stats[a].sum

  lp = 1
  lastSum = 0;

  sortedUsers.reduce(
    (msg, user, key) ->
      if lastSum != stats[user].sum
        lp = (key + 1) 
        lastSum = stats[user].sum

      return msg if lp > 5 || stats[user].sum == 0

      msg + lp + ". " +
      user + " - " + stats[user].sum + " (" +
      (stats[user]["blog-posts"] || 0) + " / " +
      (stats[user]["conference-presentations"] || 0) + " / " +
      (stats[user]["meetup-presentations"] || 0) + ")\n"
    ""
  )

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

      msg.send "W tym roku:\n" +
      yearRanking +
      "\n" +
      "W tym miesiącu:\n" +
      monthRanking +
      "\n" +
      "* Lp. Kto - Suma (Blogi / Konferencyjki / Meetupy)\n"

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
