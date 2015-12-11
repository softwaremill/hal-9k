# Description:
#   Generates memes via the Imgflip Meme Generator API
#
# Dependencies:
#   None
#
# Configuration:
#   IMGFLIP_API_USERNAME [optional, overrides default imgflip_hubot account]
#   IMGFLIP_API_PASSWORD [optional, overrides default imgflip_hubot account]
#
# Commands:
#   hubot aliens <text> - gość z Ancient Aliens History Channel
#   hubot brace yourselves <text> - Brace Yourselves X is Coming (Imminent Ned, Game of Thrones)
#
# Author:
#   dylanwenzlau


inspect = require('util').inspect

module.exports = (robot) ->
  unless robot.brain.data.imgflip_memes?
    robot.brain.data.imgflip_memes = [
      {
        regex: /aliens ()(.*)/i,
        template_id: 101470
      },
      {
        regex: /(brace yoursel[^\s]+) (.*)/i,
        template_id: 61546
      }
    ]

  for meme in robot.brain.data.imgflip_memes
    setupResponder robot, meme

setupResponder = (robot, meme) ->
  robot.respond meme.regex, (msg) ->
    generateMeme msg, meme.template_id, msg.match[1], msg.match[2]

generateMeme = (msg, template_id, text0, text1) ->
  username = process.env.IMGFLIP_API_USERNAME
  password = process.env.IMGFLIP_API_PASSWORD

  if (username or password) and not (username and password)
    msg.reply 'Brak użytkownika i hasła aby używać imgflip :('
    return

  if not username
    username = 'imgflip_hubot'
    password = 'imgflip_hubot'

  msg.http('https://api.imgflip.com/caption_image')
  .query
      template_id: template_id,
      username: username,
      password: password,
      text0: text0,
      text1: text1
  .post() (error, res, body) ->
    if error
      msg.reply "Ups! Jakiś błąd:", inspect(error)
      return

    result = JSON.parse(body)
    success = result.success
    errorMessage = result.error_message

    if not success
      msg.reply "Imgflip API boom boom: #{errorMessage}"
      return

    msg.send result.data.url