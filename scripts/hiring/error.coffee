module.exports = (msg) ->
  (err) ->
    msg.reply("Sorry, #{err}")