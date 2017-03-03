# Description:
#   ScalaTimes manager
#
# Commands:
#    hubot scalatimes|st ls - wyświetla aktualny numer
#    hubot scalatimes|st add [reading|code|event] @link - dodaje link do kategorii READING|RELEASES|EVENTS (domyślnie READING)


dao = require './scalatimes/scalaTimesDao'
usage =
     """
      Usage:
        hubot scalatimes|st ls - wyświetla aktualny numer
        hubot scalatimes|st add [reading|code|event] @link - dodaje link do kategorii READING|RELEASES|EVENTS (domyślnie READING)
      """

module.exports = (robot) ->
  linkAddShortRegex = /(scalatimes|st)\sadd\s(\S+)$/i
  linkAddRegex = /(scalatimes|st)\sadd\s(reading|code|event)\s(\S+)$/i
  listIssueRegex = /(scalatimes|st)\sls/i
  STCommandRegex = /(scalatimes|st).*/
  robot.respond linkAddShortRegex, (msg) ->
    addLink(msg, robot,msg.match[2])
  robot.respond linkAddRegex, (msg) ->
    addLink(msg, robot,msg.match[3],msg.match[2])
  robot.respond listIssueRegex, (msg) ->
    listIssue(msg, robot)
  robot.respond STCommandRegex, (msg) ->
    command = msg.match[0]
    msg.reply(usage) unless (
        (command.match linkAddRegex)? or
        (command.match linkAddShortRegex)?
        (command.match listIssueRegex)?
    )

listIssue = (msg, robot) ->
  categoriesPrettyPrint = (categories) ->
    linksPrettyPrint = (links) -> links.map((link) -> "#{link.title}").join("\n\t")
    categories.map((category) -> "#{category.name}:\n\t#{linksPrettyPrint(category.links)}").join("\n")

  onError = (err) ->
    msg.reply("Błąd w trakcie listowania: #{err}")

  onSuccess = (data) ->
    categories = JSON.parse(data)
    msg.reply(categoriesPrettyPrint(categories))

  dao.getCategories(robot, onSuccess, onError)

addLink = (msg,robot,link,categoryCmd="reading") ->
  commandCategoryMap = []
  commandCategoryMap["reading"] = "READING"
  commandCategoryMap["code"] = "RELEASES"
  commandCategoryMap["event"] = "EVENTS"
  categoryName = commandCategoryMap[categoryCmd]

  onSuccess = () ->
    msg.reply("Dodano link")
  onError = (err) ->
    msg.reply("Błąd w trakcie dodawania linka: #{err}")

  onCatgoriesFetched = (data) ->
    categories = JSON.parse(data)
    categoryId = categories.filter((cat) -> cat.name == categoryName).map((cat) -> cat.id)[0]
    if categoryId?
      dao.addLink(categoryId,link,robot,onSuccess,onError)
    else
      msg.reply("Błąd. Nie istnieje kategoria o nazwie #{categoryName}")

  dao.getCategories(robot,onCatgoriesFetched,onError)



