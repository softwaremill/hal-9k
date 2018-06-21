module.exports.getUser = (robot, username) ->
  for own key, user of robot.brain.data.users
    if username.toLowerCase() == user.name.toLowerCase()
      return user

module.exports.getUserByDisplayName = (robot, username) ->
  for own key, user of robot.brain.data.users
    displayName = user.slack?.profile?.display_name || user.name
    active = user.slack?.deleted != true
    if username == displayName and active
      return user

module.exports.getAllUsers = (robot) ->
  usersAsList = for key, user of robot.brain.data.users
    user

  return usersAsList

