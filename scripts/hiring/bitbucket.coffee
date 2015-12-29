_ = require 'lodash'
moment = require 'moment'
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

getRepositoryStats = (name, robot, successCallback, errorCallback) ->
  computeStats = (repository) ->
    (commits) ->
      actualCommits = _.reject(commits.values, (commit) -> _.startsWith(commit.message, 'Zadanie'))
      successCallback
        createdOn: formatDate(repository.created_on)
        numberOfCommits: actualCommits.length
        lastCommitOn: if actualCommits.length > 0 then formatDate(actualCommits[0].date) else null

  getCommits = (repository) ->
    get("/2.0/repositories/softwaremill/#{name}/commits", robot, parseJson(computeStats(repository)), errorCallback)

  get("/2.0/repositories/softwaremill/#{name}", robot, parseJson(getCommits), errorCallback)

parseJson = (callback) ->
  (json) ->
    callback(JSON.parse(json))

formatDate = (date) ->
  moment(date).format('YYYY-MM-DD [o] HH:mm')

httpRequest = (f, successCallback, errorCallback) ->
  f (err, res, body) ->
    if err?
      console.log("Error in request to Bitbucket API: " + err)
      errorCallback err
    else if res.statusCode isnt 200
      console.log("Error response from Bitbucket API: " + err)
      errorCallback res
    else
      successCallback(body)

extractRepositoryName = (query) ->
  matches = query.match(/(.*)#.*#/)
  if matches? and matches[1].length > 0

    matches[1]
      .toLowerCase()
      .replace '#', ''
      .trim()
      .replace ' ', '_'
      .replace 'ą', 'a'
      .replace 'ć', 'c'
      .replace 'ę', 'e'
      .replace 'ł', 'l'
      .replace 'ń', 'n'
      .replace 'ó', 'o'
      .replace 'ś', 's'
      .replace 'ż', 'z'
      .replace 'ź', 'z'

authenticated = (url, robot) ->
  robot.http("https://api.bitbucket.org/#{url}").auth(USERNAME, PASSWORD)

get = (url, robot, successCallback, errorCallback) ->
  httpRequest(authenticated(url, robot).get(), successCallback, errorCallback)

postJson = (url, data, robot, successCallback, errorCallback) ->
  httpRequest(authenticated(url, robot).header('Content-Type', 'application/json').post(JSON.stringify(data)),
    successCallback, errorCallback)

put = (url, data, robot, successCallback, errorCallback) ->
  httpRequest(authenticated(url, robot).put(data), successCallback, errorCallback)

module.exports =
  createRepositoryAndGrantAccess: createRepositoryAndGrantAccess
  getRepositoryStats: getRepositoryStats
  extractRepositoryName: extractRepositoryName