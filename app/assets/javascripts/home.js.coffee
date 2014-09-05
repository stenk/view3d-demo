angular.module 'view3dDemo', ['view3d']

  .controller 'DemoCtrl', ($scope) ->
    $scope.models = [
      { title: 'Male', src: '/models/male02.obj', scale: 0.4 }
      { title: 'Female', src: '/models/Talia.obj', scale: 0.4 }
      { title: 'Tree', src: '/models/tree.obj', scale: 40 }
      { title: 'Plane', src: '/models/B-747.obj', scale: 1 }
      { title: 'Golfball', src: '/models/golfball_lowpoly.obj', scale: 15 }
      { title: 'Tavern', src: '/models/building.obj', scale: 0.02 }
    ]

    $scope.displayModel = (model) ->
      $scope.modelSrc = model.src
      $scope.modelScale = model.scale

    $scope.displayModel($scope.models[0])
