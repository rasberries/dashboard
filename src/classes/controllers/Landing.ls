const SECTIONS = [\rasp \about \linux \macos]; Sections = new IS.Enum SECTIONS

class LandingController extends IS.Object
	~>
	init: (@scope, @runtime) ~> 
		@config-scope!
		@init-runtime!

	init-runtime: ~>
		@scope.sections = {}
		for section in SECTIONS
			@scope.sections[section] = DepMan.render [\pages \landing section]*"/"
		window.add-event-listener "resize", ~> @safeApply?!

	config-scope: ~>
		@safeApply = (fn) ~>
			phase = @scope.$parent.$$phase
			if phase is "$apply" or phase is "$digest"
				if fn and (typeof(fn) is 'function')
					do fn
			else @scope.$apply(fn)
		@scope <<< @

	read-more: ~>
		unless window.location.toString!indexOf('#about') >= 0
			window.location = window.location + '#about'

	height: (style) ~> switch style
	| \login => height: window.innerHeight - 300 + "px"
	| \full => height: window.innerHeight + "px"

Controller = new LandingController()
angular.module AppInfo.displayname .controller "Landing", ["$scope", "Runtime", Controller.init]
module.exports = Controller
