# Description:
#   Contact command logic
#
# Commands:
#  hubot telefon @username - wyświetla numer telefonu do osoby
#  hubot adres @username - wyświetla adres do osoby
#  hubot skype @username - wyświetla skyeId do osoby
#  hubot kontakt @username - wyświetla wszystkie dane kontaktowe do osoby

backend = require './common/backend'

HIRING_ROOM_NAME = process.env.HUBOT_HIRING_ROOM_NAME

module.exports = (robot) ->
  robot.respond /(telefon|skype|adres|kontakt)\s?((.*\s*)+)/i, (msg) ->

    onError = (err) ->
      msg.reply("Błąd: #{err}")

    onSuccess = (data) ->
      response = JSON.parse(data)
      msg.send "Dane kontaktowe: #{response.message}"

    queryForContactDetails = (robot, user, contactData) ->
      backend.get "/contacts/#{user}/#{contactData}", robot, onSuccess, onError

    action = msg.match[1]
    slackUser = msg.match[2]
    if !slackUser
      msg.reply "Musisz podać użytkownika"
    else
      if slackUser is 'help'
        showUsage robot, msg
      else
        msg.reply "Już się robi ... tylko to chwilę potrwa ;-)"
        switch action
          when 'telefon' then queryForContactDetails robot, slackUser, "telefon"
          when 'skype' then queryForContactDetails robot, slackUser, "skype"
          when 'adres' then queryForContactDetails robot, slackUser, "adres"
          when 'kontakt' then queryForContactDetails robot, slackUser, "all"

showUsage = (robot, msg) ->
  msg.send """
        telefon @username - wyświetla numer telefonu do osoby
        adres @username - wyświetla adres do osoby
        skype @username - wyświetla skyeId do osoby
        kontakt @username - wyświetla wszystkie dane kontaktowe do osoby
      """
