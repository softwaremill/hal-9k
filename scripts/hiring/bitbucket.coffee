backend = require '../common/backend'

USERNAME = process.env.HUBOT_BITBUCKET_USERNAME
PASSWORD = process.env.HUBOT_BITBUCKET_PASSWORD
TASK_URL = process.env.HUBOT_HIRING_TASK_URL

LOCAL_TASK_FILE = 'zadanie.pdf'
BASE_REPOSITORY_URL = 'https://bitbucket.org/softwaremill/'

createRepositoryAndGrantAccess = (name, allowedLogin, robot, successCallback, errorCallback) ->
  onSuccess = ->
    successCallback("#{BASE_REPOSITORY_URL}#{name}")

  grantAccess = ->
    put("/1.0/privileges/softwaremill/#{name}/#{allowedLogin}", 'write', robot, onSuccess, errorCallback)

  initialize = ->
    backend.put('/hiring/repository', repositoryName: name, robot, grantAccess, errorCallback)

  createRepository = ->
    data =
      scm: 'git'
      is_private: true
      fork_policy: 'no_public_forks'

    postJson("/2.0/repositories/softwaremill/#{name}", data, robot, initialize, errorCallback)

  createRepository()

httpRequest = (f, successCallback, errorCallback) ->
  f (err, res) ->
    if err?
      errorCallback err
    else if res.statusCode isnt 200
      errorCallback res.statusCode
    else
      successCallback()

authenticated = (url, robot) ->
  robot.http("https://api.bitbucket.org/#{url}").auth(USERNAME, PASSWORD)

postJson = (url, data, robot, successCallback, errorCallback) ->
  httpRequest(authenticated(url, robot).header('Content-Type', 'application/json').post(JSON.stringify(data)),
    successCallback, errorCallback)

put = (url, data, robot, successCallback, errorCallback) ->
  httpRequest(authenticated(url, robot).put(data), successCallback, errorCallback)

module.exports =
  createRepositoryAndGrantAccess: createRepositoryAndGrantAccess