# Description:
#   Status check endpoint

module.exports = (robot) ->

  robot.router.post '/status', (req, res) ->
    robot.logger.info "Registering status #{JSON.stringify req.body}"

    robot.brain.set 'status', req.body.test
    res.send 'success'

  robot.router.get '/status', (req, res) ->
    status = robot.brain.get 'status'
    robot.logger.info "Status check #{status}"
    res.send status or 'NoOk'

  robot.error (err, res) ->
    robot.logger.error "Does not compute"
    if res?
      res.reply "Does not compute :("
