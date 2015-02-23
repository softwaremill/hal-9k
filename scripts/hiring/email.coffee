sendgrid = require('sendgrid')(process.env.SENDGRID_USERNAME, process.env.SENDGRID_PASSWORD)
fs = require 'fs'

SUBJECT_PREFIX = '[SoftwareMill]'

sendSurvey = (to, successCallback, errorCallback) ->
  body = emailTemplate('ankieta')
  send(to, 'Ankieta', body, successCallback, errorCallback)

sendTask = (to, repositoryUrl, successCallback, errorCallback) ->
  body = emailTemplate('zadanie').replace(/#url#/, repositoryUrl)
  send(to, 'Zadanie', body, successCallback, errorCallback)

send = (to, subject, body, successCallback, errorCallback) ->
  email = new sendgrid.Email(
    to: to
    from: 'pani.halinka.od.hr@softwaremill.com'
    fromname: 'Urocza Pani Halinka od HR–ów w SoftwareMill'
    cc: 'czlowieki@softwaremill.com'
    subject: "#{SUBJECT_PREFIX} #{subject}"
    text: body
  )

  sendgrid.send(email, (err) ->
    if err?
      errorCallback err
    else
      successCallback()
  )

emailTemplate = (templateName) ->
  fs.readFileSync("./scripts/hiring/email_templates/#{templateName}.txt").toString()

module.exports =
  sendSurvey: sendSurvey
  sendTask: sendTask