angular.module 'view3d', []

  .factory 'Player', ->
    class Player
      constructor: ->
        @container = null
        @renderer = null
        @scene = null
        @camera = null
        @model = null

      setupRenderer: (element) ->
        @renderer = new THREE.WebGLRenderer(antialias: true)
        @renderer.setClearColor 0x333333, 1

        @container = element
        $(@renderer.domElement).css display: 'block'
        @container.append @renderer.domElement

      setupScene: ->
        @scene = new THREE.Scene()

        @camera = new THREE.PerspectiveCamera(45, 1, 1, 2000)
        @camera.position.z = 100
        @scene.add @camera

        ambient = new THREE.AmbientLight(0x101010)
        @scene.add ambient

        directionalLight = new THREE.DirectionalLight(0xffffff)
        directionalLight.position.set 0, 0, 1
        @scene.add directionalLight

      setupBounds: ->
        viewportWidth = @container.width()
        viewportHeight = @container.height()

        @renderer.setSize viewportWidth, viewportHeight
        @camera.aspect = viewportWidth / viewportHeight
        @camera.updateProjectionMatrix()

      setupModel: (scope) ->
        manager = new THREE.LoadingManager()
        loader = new THREE.OBJLoader(manager)
        loader.load scope.src
          , (newModel) =>
            @model = newModel
            @scene.add @model
            @scaleModel(scope.scale)

            # center model
            box = new THREE.Box3()
            box.setFromObject(@model)
            @model.position.sub(box.center())

          , (progress) =>
            @scene.remove(@model) if @model
            percents = progress.loaded / progress.totalSize * 100
            scope.modelLoadingProgress = Math.round(percents) + '%'
            scope.$apply()

      setupAnimation: (scope) ->
        fn = =>
          requestAnimationFrame fn
          if @model && scope.rotation
            delta = 0.01 * scope.rotationSpeed
            @model.rotation.y += delta
          @renderer.render @scene, @camera

        fn()

      scaleModel: (scale) ->
        @model.scale.multiplyScalar(scale) if @model

      containerBoundsString: ->
        @container.width() + 'x' + @container.height()

  .directive 'view3d', ->
    restrict: 'E'
    scope:
      src: '=', scale: '=?'
      rotation: '=?', rotationSpeed: '=?'

    controller: ($scope, $element, Player) ->
      # set default property values
      $scope.scale ?= 1
      $scope.rotation ?= true
      $scope.rotationSpeed ?= 1

      # check if WebGL is supported
      return if $scope.webglError = !Detector.webgl

      # init player
      player = new Player
      player.setupRenderer($element)
      player.setupScene()
      player.setupAnimation($scope)

      # watches
      $scope.$watch player.containerBoundsString.bind(player), -> player.setupBounds()
      $scope.$watch 'scale', -> player.scaleModel($scope.scale)
      $scope.$watch 'src', -> player.setupModel($scope)

      # scope methods
      $scope.toggleRotation = -> $scope.rotation = !$scope.rotation
      $scope.resetModelRotation = -> model.rotation.y = 0

    template: '''
      <div class="view3d-error" ng-if="webglError">
        WebGL is not supported by your browser
      </div>

      <div class="control-panel" ng-if="!webglError">
        <div class="loading-progress" ng-if="modelLoadingProgress != '100%'">
          Loading: <b>{{ modelLoadingProgress }}</b>
        </div>

        <div class="buttons">
          <div class="stop-rotation button fa fa-pause"
               ng-if="rotation"
               ng-click="toggleRotation()">
          </div>
          <div class="start-rotation button fa fa-play"
              ng-if="!rotation"
              ng-click="toggleRotation()">
          </div>
          <div class="reset-rotation button fa fa-home"
               ng-click="resetModelRotation()">
          </div>
        </div>
      </div>
    '''
