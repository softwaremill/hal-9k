# Description:
#   Topdown project specific commands
#
# Commands:
#   hubot td|topdown zoom|backlog|planning|standup - shows link to Zoom

module.exports = (robot) ->

  robot.respond /(td|topdown) (zoom|standup)/i, (res) ->
    res.send 'Standup jest na <https://zoom.us/j/95053332039?pwd=QmJ0ZzR1ZVFnMTNkMG9URjlnWlc5QT09|Zoom>'

  robot.respond /(td|topdown) (backlog|planning)/i, (res) ->
    res.send 'Sprint Planing jest na <https://zoom.us/j/91733987005?pwd=YlBQaWRkRkN6cE9JZjMxbXhoeGFiQT09|Zoom>'
