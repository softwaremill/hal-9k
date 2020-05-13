# Description:
#   Zwraca statystyki na podstawie nastrójów (moods) zbieranych przez /out [1-5]
#
# Commands:
#   hubot moodStats - zwraca średnie nastroje w firmie od początku pomiarów
#   hubot moodStats <year> <month> - zwraca średnie nastroje za dany miesiąc

moodDao = require './mood/moodDao'

module.exports = (robot) ->

  getMoodStats = (res) ->
    res.finish()

    res.reply("Proszę o cierpliwość, liczę ...")
    moodDao.getMoodStats(robot, res)

  getMoodStatsForMonth = (res) ->
    res.finish()
    params = res.match[1].match /(\d*)\s(\d*)/
    robot.logger.info "Extracting year and month [#{params}]"

    if (params is null or params.length != 3)
      return res.reply "Poprawne użycie: moodStats <rok> <miesiac> e.g. stats 2020 02"

    moodDao.getMoodStatsForMonth(robot, res, params[1], params[2])

  robot.respond /moodStats$/i, getMoodStats
  robot.respond /moodStats (.*)/i, getMoodStatsForMonth
