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

  robot.hear /.*ale faza.*|.*ale mam faz(.).*|.*faza na ca(.)ego.*/i, (res) ->
    res.send "Ty masz fazę? Patrz jaką @bartek miał fazę! https://janusz-the-bot.sml.io/memes/ale-faza-ea6de795-dbb7-4f55-931a-0a7b7ffaa2c6.jpg"
