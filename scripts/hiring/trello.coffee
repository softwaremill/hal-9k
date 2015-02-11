_ = require('lodash');

module.exports = (boardId, key, token) ->
  findCard = (query, robot, successCallback, errorCallback) ->
    searchParams =
      modelTypes: 'cards'
      idBoards: boardId
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
      key: key
      token: token

    robot.http(url)
    .query(_.assign(trelloKeyAndToken, queryParams))
    .get() (err, res, body) ->
      if err
        errorCallback err
      else
        successCallback JSON.parse(body)

  return {
    findCard: findCard,
    findListByCardQuery: findListByCardQuery
  }