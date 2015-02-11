# Description:
#   Shows random troll picture
#
# Commands:
#   hubot troll - shows random troll picture

module.exports = (robot) ->
  robot.respond /troll?/i, (msg) ->
    imageMe msg, "troll", (url) ->
      msg.send url

imageMe = (msg, query, cb) ->
  q = v: '1.0', rsz: '8', q: query, safe: 'active'
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
  .query(q)
  .get() (err, res, body) ->
    images = JSON.parse(body)
    images = images.responseData?.results
    if images?.length > 0
      image  = msg.random images
      cb "#{image.unescapedUrl}#.png"
