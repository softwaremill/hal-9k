# Description:
#   Topdown project specific commands
#
# Commands:
#   hubot td|topdown zoom|backlog|planning - shows link to Zoom
#   hubot td|topdown standup - shows link to Hangout

module.exports = (robot) ->

  robot.respond /(td|topdown) (zoom|backlog|planning)/i, (res) ->
    res.send 'Spotkanie na Zoomie jest tutaj https://zoom.us/j/2716999780'

  robot.respond /(td|topdown) standup/i, (res) ->
    res.send 'Spotkanie na Hangoutcie jest tutaj https://meet.google.com/vpy-uebc-pex'
