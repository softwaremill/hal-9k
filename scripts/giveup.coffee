# Description:
#   Shows funny bunny gif
#
# Commands:

URL = 'https://cloud.githubusercontent.com/assets/4712360/12327173/366de5ea-bad5-11e5-9eff-f58ef3dd8120.gif'

module.exports = (robot) ->
  robot.hear /^(poddaje się)|(mam dość)|(give up)$/i, (msg) ->
    msg.send "Nie przejmuj się, inni mają gorzej! #{URL}"
