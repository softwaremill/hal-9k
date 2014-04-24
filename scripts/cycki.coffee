# Description:
#   Messing around with the YouTube API and Google Images.
#
# Commands:
#   hubot cycki

sources = ['yt', 'img']

module.exports = (robot) ->
  robot.respond /cycki/i, (msg) ->
    source = msg.random sources
    if source == 'yt'
      yt robot, msg
    else
      imageMe msg

yt = (robot, msg) ->
  robot.http("http://gdata.youtube.com/feeds/api/videos")
  .query({
        orderBy: "relevance"
        'max-results': 15
        alt: 'json'
        q: 'cycki'
      })
  .get() (err, res, body) ->
    videos = JSON.parse(body)
    videos = videos.feed.entry

    unless videos?
      msg.send "Nie ma cycków :("
      return

    video  = msg.random videos
    video.link.forEach (link) ->
      if link.rel is "alternate" and link.type is "text/html"
        msg.send link.href

imageMe = (msg) ->
  q = v: '1.0', rsz: '8', q: 'cycki'
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
  .query(q)
  .get() (err, res, body) ->
    images = JSON.parse(body)

    images = images.responseData?.results

    unless images?
      msg.send "Nie ma cycków :("
      return

    if images?.length > 0
      image  = msg.random images
      msg.send image.unescapedUrl
