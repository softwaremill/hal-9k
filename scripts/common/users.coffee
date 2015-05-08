module.exports.getUser = (robot, username) ->
  for own key, user of robot.brain.data.users
    if username.toLowerCase() == user.name.toLowerCase()
      return user

module.exports.getAllUsers = (robot) ->
  return robot.brain.data.users
