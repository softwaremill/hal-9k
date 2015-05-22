store = {}

module.exports.add = (user) ->
  store[user] = store[user] || []
  store[user].push((new Date()).getTime())

module.exports.countInTimespan = (user, timespanInSeconds) ->
  discardOutdated(timespanInSeconds)
  return {
    count: store[user].length
    firstTimestamp: store[user][0]
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

