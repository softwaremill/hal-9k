# Description:
#   To add and show kudos
#
# Commands:
#   hubot kudos help - pokazuje pomoc dla modułu kudos
#

users = require './common/users'
kudos = require './kudos/kudosDao'

KUDOS_REACTION = 'kudos'

module.exports = (robot) ->
  displayKudos = (robot, res, kudos, kudosUser) ->
    attachments = []
    for kudos in JSON.parse(kudos)
      attachments.push
        text: "- od *#{kudos.kudoer.name}*: #{kudos.description}",
        mrkdwn_in: ["text"]

    response =
      text: "Kudosy dla *#{kudosUser}*:"
      attachments: attachments
      username: robot.name
      as_user: true

    robot.messageRoom res.message.user.id, response

  showKudos = (res, kudosUser) ->
    user = users.getUser(robot, kudosUser)
    if (user == undefined)
      res.reply "Nie znam żadnego #{kudosUser}."
    else
      successHandler = (body) ->
        displayKudos(robot, res, body, kudosUser)

      errorHandler = (err, errCode) ->
        robot.logger.error "Error getting kudos from the backend. Error: #{error}"
        res.reply("Error #{errCode}")

      kudos.getKudos(robot, user.id, successHandler, errorHandler)

  robot.respond /kudos (show|pokaż dla) @?(.*)/i, (res) ->
    showKudos res, res.match[2]
  robot.respond /poka(z|ż) kudos(y)? (dla )?@?(\S+)/i, (res) ->
    showKudos res, res.match[4]

  addKudos = (res, kudosReceiver, kudosDesc) ->
    user = users.getUser(robot, kudosReceiver)
    if (user == undefined)
      res.reply "Nie znam żadnego #{kudosReceiver}."
    else
      successHandler = (successBody) ->
        jsonBody = JSON.parse(successBody)
        robot.messageRoom res.message.user.id, "Ok, kudos dodany. ID=#{jsonBody.id}"

      errorHandler =
        (err, errCode) -> res.reply("Error #{errCode}")

      robot.logger.info "Adds a new kudos based on message id: #{res.message.id}"
      kudos.addKudos(robot, successHandler, errorHandler, res.message.user.id, user.id, kudosDesc, res.message.id)

  robot.respond /kudos (add|dodaj dla) @?(\S*) (.*)/i, (res) ->
    kudosReceiver = res.match[2]
    kudosDesc = res.match[3]
    addKudos(res, kudosReceiver, kudosDesc)

  robot.respond /(do)?daj kudos(a?) @?(\S*) (.*)/i, (res) ->
    kudosReceiver = res.match[3]
    kudosDesc = res.match[4]
    addKudos(res, kudosReceiver, kudosDesc)


  robot.hear /.*(dziękuję|dzięki|dziekuje|dzieki|thx|thanks).*/i, (res) ->
    robot.messageRoom res.message.user.id, "A może tak dać kudosa? A jak dać kudosa to pisz `janusz kudos help` :)"

  matchingReaction = (msg) ->
    robot.logger.info "Heard reaction #{msg.type} #{msg.reaction} from #{msg.user.name} in #{msg.item.channel} on #{msg.item.ts}"
    msg.type == 'added' and msg.reaction == KUDOS_REACTION and msg.item.type == 'message'

  handleReaction = (res) ->
    onSuccess = (body) ->
      robot.logger.info "Response from backend: #{body}"
      jsonBody = body
      try
        jsonBody = JSON.parse(body)
      catch error
        robot.logger.error "Cannot parse #{body} as JSON, got error: #{error}"

      if jsonBody.error
        robot.logger.error jsonBody.message
        robot.messageRoom res.message.user.id, "Coś poszło nie tak: #{jsonBody.message}"
      else if jsonBody.id
        robot.messageRoom res.message.user.id, "Ok, kudos dodany. ID=#{jsonBody.id}"
      else if jsonBody.message
        robot.messageRoom res.message.user.id, "Ok, kudos dodany. Status=#{jsonBody.message}"
      else
        robot.messageRoom res.message.user.id, "Ok, kudos dodany. Status=#{body}"

    onError =
      (err, errCode) ->
        robot.messageRoom res.message.user.id, "Upss... coś poszło nie tak przy dodawniu :+1: do kudosa: (#{errCode}) #{error}"

    response = robot.adapter.client.web.reactions.get
      channel: res.message.item.channel
      timestamp: res.message.item.ts

    response.then (result) ->
      if result.ok
        robot.logger.info "Got reaction's message: #{result.message.text}"

        reactions = (reaction for reaction in result.message.reactions when reaction.name is KUDOS_REACTION)

        if reactions.length == 1
          robot.logger.info "No kudos reactions yet, adding a new kudos for message id: #{res.message.item.ts}"
          kudos.addKudos(robot, onSuccess, onError, res.message.user.id, res.message.item_user.id, result.message.text, res.message.item.ts)
        else
          robot.logger.info "Kudos already added, do plus one"
          kudos.addPlusOneByMessageId(robot, onSuccess, onError, res.message.user.id, res.message.item.ts)
      else
        robot.logger.error result.error

  robot.hearReaction matchingReaction, handleReaction

  robot.respond /kudos (help|pomoc)/i, (res) ->
    kudosAppLogin = process.env.HUBOT_KUDOS_APP_LOGIN
    kudosAppPassword = process.env.HUBOT_KUDOS_APP_PASSWORD
    robot.messageRoom res.message.user.id, """
      `kudos pomoc|help` - wyświetla tę pomoc
      `pokaż kudos(y) <nazwa>` - listuje kudosy dla użytkownika <nazwa>
      `kudos pokaż dla <nazwa>` - j.w.
      `kudos show <nazwa>` - j.w. (przestarzałe, nie używać!)
      `(do)daj kudos(a) <nazwa> <treść>` - dodaje kudosa o treści <treść> dla użytkownika <nazwa>
      `kudos dodaj dla <nazwa> <treść>` - j.w.
      `kudos add <nazwa> <treść>` - j.w. (przestarzałe, nie używać!)

      Możesz również dać :kudos: na czyjejś wiadomości aby dać tej osobie Kudosa za tę właśnie wiadomość!

      Kilkając :+1: pod czyimś kudosem (danym za pomocą `janusz daj kudos...`), podbijasz o jeden obdarowanego kudosem.

      Kudosy są dostępne na stronie http://kudos.softwaremill.com
      Login: #{kudosAppLogin}
      Hasło: #{kudosAppPassword}
    """