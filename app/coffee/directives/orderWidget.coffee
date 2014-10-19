define([
  'angular'
  'models/Map'
  'wsService'
  'directives/directives'
], (
  angular
  Map
  ws
  directives
) ->
  'use strict'

  typeSymbols =
    "Move": "&rarr;"
    "Support": "S"
    "Hold": "H"
    "Convoy": "C"
    "Build": "B"
    "Disband": "D"

  secondaryTypeSymbols =
    "Move": ""
    "Support": "&rarr;"
    "Hold": ""
    "Convoy": "&rarr;"
    "Build": ""
    "Disband": ""

  angular.module('diplomacyDirectives')
    .directive('orderWidget', ['wsService', (ws) ->
      {
        templateUrl: 'templates/orderWidget.html'
        replace: true
        restrict: 'E'
        link: ($scope) ->
          console.debug "Order widget linking"

          $scope.cancelOrder = ->
            $scope.lieutenant.cancelOrder()

          $scope.commitOrders = ->
            ws.sendRPC("Commit", { "PhaseId": $scope.game.Phase.Id }, ->
              $scope.$apply ->
                $scope.lieutenant.player.Committed = true
            )

          $scope.uncommitOrders = ->
            ws.sendRPC("Uncommit", { "PhaseId": $scope.game.Phase.Id }, ->
              $scope.$apply ->
                $scope.lieutenant.player.Committed = false
            )

          $scope.sendOrders = ->
            _.chain($scope.lieutenant.orders.orders)
              .filter((order) -> (not order.committed))
              .each((order) ->
                ws.sendRPC(
                  "SetOrder"
                  {
                    "GameId": $scope.game.Id
                    "Order": order.toDiplicity()
                  }
                  ((iOrder) ->
                    ->
                      $scope.$apply ->
                        iOrder.committed = true
                  )(order)
                )
                console.debug "Sent", order.toDiplicity()
              )

          $scope.typeSymbols = typeSymbols

          $scope.secondaryTypeSymbols = secondaryTypeSymbols
      }
    ])
    .directive('existingOrder', ['wsService', (ws) ->
      {
        templateUrl: 'templates/existingOrder.html'
        replace: true
        restrict: 'E'
        scope:
          order: "="
          game: "="
          lieutenant: "="
        link: ($scope) ->
          console.debug "Existing order widget linking"

          $scope.typeSymbols = typeSymbols

          $scope.secondaryTypeSymbols = secondaryTypeSymbols

          $scope.deleteOrder = (order) ->
            ws.sendRPC(
              "SetOrder"
              {
                "GameId": $scope.game.Id
                "Order": [ order.unit_area ]
              }
              ((iOrder) ->
                ->
                  $scope.lieutenant.deleteOrder(iOrder)
              )(order)
            )
            console.debug "Sent order deletion (#{order.unit_area})"
      }
    ])
)
