_ = require('lodash');

BOARD_ID = process.env.HUBOT_HIRING_BOARD_ID
KEY = process.env.HUBOT_TRELLO_KEY
TOKEN = process.env.HUBOT_TRELLO_TOKEN

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

findListByCardQuery = (cardQuery, robot, successCallback, errorCallback) ->
  getListForCard = (card) ->
    get("https://api.trello.com/1/lists/#{card.idList}", {}, robot, successCallback, errorCallback)

  findCard(cardQuery, robot, getListForCard, errorCallback)

get = (url, queryParams, robot, successCallback, errorCallback) ->
  trelloKeyAndToken =
    key: KEY
    token: TOKEN

  robot.http(url)
  .query(_.assign(trelloKeyAndToken, queryParams))
  .get() (err, res, body) ->
    if err
      errorCallback err
    else
      successCallback JSON.parse(body)

module.exports =
  findCard: findCard,
  findListByCardQuery: findListByCardQuery