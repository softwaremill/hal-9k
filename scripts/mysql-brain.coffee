# Description:
#   A hubot script to persist hubot's brain using MySQL
#
# Configuration:
#   MYSQL_URL mysql://user:pass@host/db
#   MYSQL_TABLE brain
#
# Commands:
#   None
#
# Author:
#   Akhyar Amarullah <akhyrul@gmail.com>

tag = 'hubot-mysql-brain'
rowId = 0
mysql = require 'mysql'

module.exports = (robot) ->
  url = process.env.MYSQL_URL
  table = process.env.MYSQL_TABLE or 'brain'

  robot.logger.info("#{tag}: Using #{url} to connect to brain")

  conn = mysql.createConnection(url)

  load_data = () ->
    conn.query "SELECT `data` FROM `#{table}` WHERE `id`= #{rowId}", (err, rows) ->
      if err or rows.length == 0
        if err
          robot.logger.error err
        if rows.length == 0
          robot.logger.info "#{tag}: No data in brain yet"
        robot.brain.mergeData {}
      else
        robot.logger.info "Mering data into brain: #{rows[rowId].data}"
        data = JSON.parse rows[0].data
        robot.brain.mergeData data

  conn.connect (err) ->
    if err?
      robot.logger.error "#{tag}: Error\n#{err}"
    else
      robot.logger.info "#{tag}: Connected to MySQL brain (table: #{table})"
      load_data()

  robot.brain.on 'save', (data = {}) ->
    brain =
      _private: data['_private']

    vals = { 'id': 0, 'data': JSON.stringify brain }
    conn.query "INSERT INTO `#{table}` SET ? ON DUPLICATE KEY UPDATE `data` = '#{JSON.stringify brain}'", vals, (err, _) ->
      if err
        robot.logger.error err
      return
