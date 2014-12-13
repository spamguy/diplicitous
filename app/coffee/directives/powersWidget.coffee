define([
  'angular'
  'directives/directives'
  'underscore'
], (
  angular
  directives
  _
) ->
  'use strict'

  angular.module('diplomacyDirectives')
    .directive('powersWidget', ->
      {
        templateUrl: 'templates/powersWidget.html'
        replace: true
        restrict: 'E'
        link: ($scope, iElem, iAttr) ->
          $scope.$watch('game', (game, oldValue) ->
            if game?
              powers = _.clone(game.Members)
              console.debug("Powers: #{powers}")
              powers = _.chain(powers)
                .map((member) -> {
                  power: member.Nation,
                  scs: game.supplyCenters(member.Nation).length 
                  units: game.units(member.Nation).length
                })
                .sortBy((pair) -> pair.scs)
                .reverse()
                .value()
              $scope.powers = powers
          )
      }
    )
)
