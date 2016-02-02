mailgun = require('mailgun-js')({apiKey: process.env.MAILGUN_APIKEY, domain: process.env.MAILGUN_DOMAIN});
fs = require 'fs'

SUBJECT_PREFIX = '[SoftwareMill]'

sendSurvey = (to, name, successCallback, errorCallback) ->
  body = emailTemplate("ankieta").replace(/#name#/, name)
  send(to, 'Ankieta', body, successCallback, errorCallback)

sendTask = (to, repositoryUrl, successCallback, errorCallback) ->
  body = emailTemplate('zadanie').replace(/#url#/, repositoryUrl)
  send(to, 'Zadanie', body, successCallback, errorCallback)

sendWelcomeMessage = (to, name, successCallback, errorCallback) ->
  body = emailTemplate('welcome').replace(/#name#/, name)
  send(to, 'Witaj, cieszymy się, że jesteś :)', body, successCallback, errorCallback)

sendOnHoldMessage = (to, name, successCallback, errorCallback) ->
  body = emailTemplate('onhold').replace(/#name#/, name)
  send(to, 'Witaj, dziękujemy za CV :)', body, successCallback, errorCallback)

send = (to, subject, body, successCallback, errorCallback) ->
  data =
    to: to,
    from: "Urocza Pani Halinka od HR–ów w SoftwareMill <pani.halinka.od.hr@softwaremill.com>",
    cc: 'czlowieki@softwaremill.com',
    subject: "#{SUBJECT_PREFIX} #{subject}",
    text: body

  mailgun.messages().send(data, (error, body) ->
    if error?
      errorCallback error
    else
      successCallback()
  )

emailTemplate = (templateName) ->
  fs.readFileSync("./scripts/hiring/email_templates/#{templateName}.txt").toString()

module.exports =
  sendSurvey: sendSurvey
  sendTask: sendTask
  sendWelcomeMessage: sendWelcomeMessage
  sendOnHoldMessage: sendOnHoldMessage