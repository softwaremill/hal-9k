store = {}

module.exports.add = (user) ->
  store[user] = store[user] || []
  store[user].push((new Date()).getTime())

module.exports.countInTimespan = (user, timespanInSeconds) ->
  discardOutdated(timespanInSeconds)
  return {
    count: if store[user]? then store[user].length else 0
    firstTimestamp: if store[user]? then store[user][0] else null
  }

module.exports.clearForUser = (user) ->
  store[user].length = 0

discardOutdated = (timeoutSec) ->
  now = new Date().getTime()
  Object.keys(store).forEach( (user) ->
    store[user] = store[user].filter( (msgTimestamp) ->
      return now - msgTimestamp <= timeoutSec * 1000
    )
  )

