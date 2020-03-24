# Description:
#   Topdown project specific commands
#
# Commands:
#   hubot td|topdown zoom|backlog|planning|standup - shows link to Zoom

module.exports = (robot) ->

  robot.respond /(td|topdown) (zoom|backlog|planning|standup)/i, (res) ->
    res.send 'Spotkanie jest na <https://zoom.us/j/2716999780|Zoom>'
