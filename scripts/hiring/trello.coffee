_ = require 'lodash'

BOARD_ID = process.env.HUBOT_HIRING_BOARD_ID

KEY_AND_TOKEN =
  key: process.env.HUBOT_TRELLO_KEY
  token: process.env.HUBOT_TRELLO_TOKEN

lists =
  new: '51acaaefbeac745c31005967'
  gotSurvey: '51ade0b03e79ff244a001071'
  preScreening: '51f63c8487eaf62c15003a51'
  taskInProgress: '51f63c74faa4a1497b00446b'
  codeReview: '51f63cb51e9bf75b7b00386e'
  technicalCall: '5478db810b6b5ab72c591a59'
  lunch: '5478db8c51399a1f75cc45b2'
  withDoubts: '51acaaefbeac745c31005969'
  rejected: '51acaaefbeac745c31005968'

findCard = (query, robot, successCallback, errorCallback) ->
  searchParams =
    modelTypes: 'cards'
    idBoards: BOARD_ID
    query: query

  extractCard = (json) ->
    switch json.cards.length
      when 0 then errorCallback "nie znalazłem kartki dla \"#{query}\""
      when 1 then successCallback json.cards[0]
      else errorCallback "znalazłem więcej niż jedną kartkę dla \"#{query}\""

  get('https://api.trello.com/1/search', searchParams, robot, extractCard, errorCallback)

findListById = (id, robot, successCallback, errorCallback) ->
  get("https://api.trello.com/1/lists/#{id}", {}, robot, successCallback, errorCallback)

extractEmailAddress = (card) ->
  matches = card.name.match(/#(.*)#/)
  matches[1] if matches?

moveToGotSurvey = (card, robot, successCallback, errorCallback) ->
  moveCardToList(card, lists.gotSurvey, robot, successCallback, errorCallback)

moveToTaskInProgress = (card, robot, successCallback, errorCallback) ->
  moveCardToList(card, lists.taskInProgress, robot, successCallback, errorCallback)

moveCardToList = (card, targetListId, robot, successCallback, errorCallback) ->
  put("https://api.trello.com/1/cards/#{card.id}/idList", {value: targetListId}, robot, successCallback, errorCallback)

isNew = (card) -> card.idList is lists.new

isPreScreening = (card) -> card.idList is lists.preScreening

isTaskInProgress = (card) -> card.idList is lists.taskInProgress

query = (url, queryParams, robot) -> robot.http(url).query(_.assign(KEY_AND_TOKEN, queryParams))

request = (f, successCallback, errorCallback) ->
  f (err, res, body) ->
    if err
      errorCallback err
    else
      successCallback JSON.parse(body)

get = (url, queryParams, robot, successCallback, errorCallback) ->
  request(query(url, queryParams, robot).get(), successCallback, errorCallback)

put = (url, queryParams, robot, successCallback, errorCallback) ->
  request(query(url, queryParams, robot).put(), successCallback, errorCallback)

module.exports =
  findCard: findCard
  findListById: findListById
  extractEmailAddress: extractEmailAddress
  moveToGotSurvey: moveToGotSurvey
  moveToTaskInProgress: moveToTaskInProgress
  isNew: isNew
  isPreScreening: isPreScreening
  isTaskInProgress: isTaskInProgress
