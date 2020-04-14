# Description:
#   Topdown project specific commands
#
# Commands:
#   hubot td|topdown zoom|backlog|planning|standup - shows link to Zoom

module.exports = (robot) ->

  robot.respond /(td|topdown) (zoom|backlog|planning|standup)/i, (res) ->
    res.send 'Spotkanie jest na <https://zoom.us/j/95270460488?pwd=WCttYkxUT3VQbFRuN2tPOVdYNDdYZz09|Zoom>'
