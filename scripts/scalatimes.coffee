# Description:
#   ScalaTimes manager
#
# Commands:
#    hubot scalatimes|st ls - wyświetla aktualny numer
#    hubot scalatimes|st catadd @category - dodaje nową kategorię
#    hubot scalatimes|st linkadd @categoryId @link - dodaje link


dao = require './scalatimes/scalaTimesDao'
usage =
     """
      Usage:
        hubot scalatimes|st ls - wyświetla aktualny numer
        hubot scalatimes|st catadd @category - dodaje nową kategorię
        hubot scalatimes|st linkadd @categoryId @link - dodaje link
      """

module.exports = (robot) ->
  linkAddRegex = /(scalatimes|st)\slinkadd\s(.+)\s(.+)/i
  categoryAddRegex = /(scalatimes|st)\scatadd\s(.+)/i
  listIssueRegex = /(scalatimes|st)\sls/i
  STCommandRegex = /(scalatimes|st).*/
  robot.respond linkAddRegex, (msg) ->
    addLink(msg, robot)
  robot.respond categoryAddRegex, (msg) ->
    addCategory(msg, robot)
  robot.respond listIssueRegex, (msg) ->
    listIssue(msg, robot)
  robot.respond STCommandRegex, (msg) ->
    command = msg.match[0]
    msg.reply(usage) unless (
        (command.match linkAddRegex)? or
        (command.match categoryAddRegex)? or
        (command.match listIssueRegex)?
    )


listIssue = (msg, robot) ->
  categoriesPrettyPrint = (categories) ->
    linksPrettyPrint = (links) -> links.map((link) -> "#{link.title} (id = #{link.id})").join("\n\t")
    categories.map((category) -> "#{category.name} (id = #{category.id}):\n\t#{linksPrettyPrint(category.links)}").join("\n")

  onError = (err) ->
    msg.reply("Błąd w trakcie listowania: #{err}")

  onSuccess = (data) ->
    categories = JSON.parse(data)
    msg.reply(categoriesPrettyPrint(categories))

  dao.getCategories(robot, onSuccess, onError)

addCategory = (msg, robot) ->
  categoryName = msg.match[2]
  onSuccess = () ->
    msg.reply("Dodano kategorię '#{categoryName}'")
  onError = (err) ->
    msg.reply("Błąd w trakcie dodawania kategorii: #{err}")
  dao.addCategory(categoryName, robot, onSuccess, onError)

addLink = (msg, robot) ->
  categoryId = msg.match[2]
  link = msg.match[3]
  onSuccess = () ->
    msg.reply("Dodano link")
  onError = (err) ->
    msg.reply("Błąd w trakcie dodawania linka: #{err}")
  dao.addLink(categoryId, link, robot, onSuccess, onError)



