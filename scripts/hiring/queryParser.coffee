module.exports.extractNameAndWelcomeName = (query) ->
  matches = query.match(/(.*)\s*\|\s*(.*)/)
  if matches? and matches.length is 3
    name: matches[1].trim()
    firstName: matches[2].trim()


