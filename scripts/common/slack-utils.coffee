slackToken = process.env.HUBOT_SLACK_TOKEN
apiUrl = process.env.SLACK_API_URL

module.exports.prepareFindMessageRequest = (robot, event) ->
  channel = event.item.channel
  messageId = event.item.ts

  return robot.http("#{apiUrl}/channels.history?channel=#{channel}&latest=#{messageId}&inclusive=true&count=1")
    .header('Content-Type', 'application/json')
    .header('Authorization', "Bearer #{slackToken}")
