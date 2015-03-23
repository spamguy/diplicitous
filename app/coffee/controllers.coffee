define([
  'angular'
  'lieutenant'
  'underscore'
], (
  angular
  Lieutenant
  _
) ->
  'use strict'

  diplomacyControllers = angular.module 'diplomacyControllers', []

  diplomacyControllers.controller('GameListCtrl', [
    '$scope'
    'GameListService'
    ($scope, GameListService) ->
      GameListService.subscribe($scope)
  ])
  .controller('GameCtrl', [
    '$scope'
    '$routeParams'
    '$interval'
    'UserService'
    'GameService'
    'wsService'
    (
      $scope
      $routeParams
      $interval
      UserService
      GameService
      wsService
    ) ->
      deregisterMap = $scope.$watch('map.loaded', (newValue, oldValue) ->
        if newValue
          GameService.subscribe($scope, $routeParams.gameId)
          UserService.subscribe($scope)

          console.debug "Start watching game to init Lieutenant"
          $scope.$watch('game', (newGame, oldGame) ->
            # if there is a new game, and if we have changed phase
            if newGame? and not (oldGame? and newGame.Phase.Ordinal == oldGame.Phase.Ordinal)
              $scope.map.refresh(newGame)

              deregisterUser = $scope.$watch('user', (newUser, oldUser) ->
                if newUser? and not _.isEmpty(newUser)
                  # we have both a game and a user
                  unless $scope.lieutenant
                    $scope.lieutenant = Lieutenant($scope, wsService).init(newGame.Phase.Type)
                  else
                    $scope.lieutenant.refresh(newGame, newUser)

                  deregisterUser()
              )

              # get initial time left
              $scope.timeLeft = newGame.timeLeft()

              # decrement per second
              $interval((-> $scope.timeLeft -= 1), 1000)

              $scope.timeLeftHumanReadable = ->
                moment.duration($scope.timeLeft, "seconds").humanize()
          )

          deregisterMap()
      )
  ])
)
