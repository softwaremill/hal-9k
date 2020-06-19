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
      successHandler = () ->
        response = robot.adapter.client.web.reactions.add(
          'white_check_mark',
          {
            channel: res.message.rawMessage.channel
            timestamp: res.message.id
          }
        )
        response
          .catch (error) ->
            robot.logger.error error
            robot.messageRoom res.message.user.id, "Ok, kudos dodany ale nie mogłem potwierdzić, że dodałem kudosa bo: #{error}"
            false
          .then (result) ->
            robot.logger.info result
            if result
              robot.messageRoom res.message.user.id, "Ok, kudos dodany!"

      errorHandler =
        (err, errCode) -> res.reply("Error #{errCode}")

      robot.logger.info "Adds a new kudos based on message id: #{res.message.id}"
      kudos.addKudos(robot, successHandler, errorHandler, res.message.user.id, user.id, kudosDesc, res.message.id)

  robot.respond /kudos (add|dodaj dla) @?(\S*) (.*)/i, (res) ->
    kudosReceiver = res.match[2]
    kudosDesc = res.match[3]
    addKudos(res, kudosReceiver, kudosDesc)

  robot.respond /(do)?daj kudos(a?)( dla)? @?(\S*) (.*)/i, (res) ->
    kudosReceiver = res.match[4]
    kudosDesc = res.match[5]
    addKudos(res, kudosReceiver, kudosDesc)

  robot.slackMessages.action 'dismiss_kudos_suggestion', (payload, respond) ->
    robot.logger.info "Handles callback: dismiss_kudos_suggestion"

    actionValue = payload.actions[0].value
    if actionValue == 'dismiss'
      respond({
        response_type: 'ephemeral',
        text: '',
        replace_original: 'true',
        delete_original:'true'
      })

  robot.hear /.*(dziękuję|dzięki|dziekuje|dzieki|thx|thanks).*/i, (res) ->
    if res.random [true, false]
      robot.logger.info "Sends notification about giving kudos"
    else
      robot.logger.info "No kudos reminder"

    text = "A może tak dać kudosa? A jak dać kudosa to pisz `janusz kudos help` :)"
    attachments = [
      text: "Dasz kudosa?",
      fallback: "Upss... ten klient nie obsługuje przycisków :("
      callback_id: "dismiss_kudos_suggestion"
      attachment_type: "default"
      actions: [
        name: "dismiss_suggestion"
        text: "Nie tym razem"
        type: "button"
        value: "dismiss"
      ]
    ]

    # temporary solution https://github.com/slackapi/hubot-slack/issues/599#issuecomment-645249121
    robot.adapter.client.web.chat.postEphemeral(
      res.message.rawMessage.channel,
      text,
      res.message.user.id,
      {
        attachments: attachments
        as_user: true
      }
    ).then (result) ->
        robot.logger.info result
      .catch (error) ->
        robot.logger.error error

  matchingReaction = (msg) ->
    robot.logger.info "Heard reaction #{msg.type} #{msg.reaction} from #{msg.user.name} in #{msg.item.channel} on #{msg.item.ts}"
    msg.type == 'added' and msg.reaction == KUDOS_REACTION and msg.item.type == 'message'

  handleReaction = (res) ->
    onSuccess = (description) ->
      handler = (body) ->
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
          robot.messageRoom res.message.user.id, "Ok, kudos dodany, id=#{jsonBody.id}: #{description}"
        else if jsonBody.message
          robot.messageRoom res.message.user.id, "Ok, kudos dodany, status=#{jsonBody.message}: #{description}"
        else
          robot.messageRoom res.message.user.id, "Hm... może się udało a może nie, status=#{body}"
      handler

    onError =
      (err, errCode) ->
        robot.messageRoom res.message.user.id, "Upss... coś poszło nie tak przy dodawniu :+1: do kudosa: (#{errCode}) #{error}"

    response = robot.adapter.client.web.reactions.get
      channel: res.message.item.channel
      timestamp: res.message.item.ts

    response.then (result) ->
      if result.ok
        robot.logger.info "Got reaction's message: #{result.message.text}"
        robot.logger.info JSON.stringify(result)
        reactions = (reaction for reaction in result.message.reactions when reaction.name is KUDOS_REACTION)

        robot.logger.info "Found reactions #{reactions.length}"

        if reactions.length == 0
          robot.messageRoom res.message.user.id, "Upss... nie ma emotki :kudos: na wiadomości!"
        else if reactions.length == 1 and reactions[0].count == 1 # if there is just one reaction with one user it means that this user just clicked it
          robot.logger.info "No kudos reactions yet, adding a new kudos for message id: #{res.message.item.ts}"
          description = "Kudos za #{result.message.permalink}"
          kudos.addKudos(robot, onSuccess(description), onError, res.message.user.id, res.message.item_user.id, description, res.message.item.ts)
        else
          robot.logger.info "Kudos already added, do plus one"
          kudos.addPlusOneByMessageId(robot, onSuccess(":+1:"), onError, res.message.user.id, res.message.item.ts)
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