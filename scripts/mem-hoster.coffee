# Description:
#   endpoint to host memes

fs = require('fs');
raw = fs.readFileSync('./scripts/memes/registry.json');
memes = JSON.parse(raw)

module.exports = (robot) ->

  robot.router.get '/memes/:memeId', (req, res) ->
    memeId = req.params.memeId
    robot.logger.info "Serving meme: #{memeId}"

    if memes[memeId]
      robot.logger.info "Meme [#{memeId}] exists: #{memes[memeId].fileName}"
      res
        .status(200)
        .type(memes[memeId].contentType)
        .sendFile "#{__dirname}/memes/#{memes[memeId].fileName}"
    else
      robot.logger.info "No meme with id #{memeId}"
      res.sendStatus 404
