# Description:
#   Messing around with the YouTube API.
#
# Commands:
#   hubot youtube me <query> - Searches YouTube for the query and returns the video embed link.

sources = ['yt', 'img']

module.exports = (robot) ->
  robot.respond /cycki/i, (msg) ->
    source = msg.random sources
    if source == 'yt'
      yt robot, msg
    else
      imageMe msg, 'cycki', true, false, (url) ->
        msg.send url

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

imageMe = (msg, query, animated, faces, cb) ->
  cb = animated if typeof animated == 'function'
  cb = faces if typeof faces == 'function'
  q = v: '1.0', rsz: '8', q: query, safe: 'active'
  q.imgtype = 'animated' if typeof animated is 'boolean' and animated is true
  q.imgtype = 'face' if typeof faces is 'boolean' and faces is true
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
  .query(q)
  .get() (err, res, body) ->
    images = JSON.parse(body)
    images = images.responseData?.results
    if images?.length > 0
      image  = msg.random images
      cb "#{image.unescapedUrl}#.png"
