STATES = [\tab1 \tab2 \tab3]; States = new IS.Enum STATES

class HelpController extends IS.Object
	~>
		window.HelpController = @
		@get-states!

	init-runtime: ~>
		@runtime.init "help-state", \number

	get-states: ~>
		@articles = []
		for state in STATES
			@articles.push DepMan.render [\help state]

	init: (@scope, @runtime) ~>
		@config-scope!
		@init-runtime!
		@hook-keyboard!

	hook-keyboard : ~>
		key = if Tester.mac then "cmd" else "ctrl"
		handle = ~>
			return if @runtime.props['app-state'] isnt 2
			@change-state it
			@safe-apply!

		jwerty.key "#{key}+[", ~> it.preventDefault!; handle -1
		jwerty.key "#{key}+]", ~> it.preventDefault!; handle 1

	config-scope: ~>
		@safeApply = (fn) ~>
			phase = @scope.$parent.$$phase
			if phase is "$apply" or phase is "$digest"
				if fn and (typeof(fn) is 'function')
					do fn
			else @scope.$apply(fn)
		@scope <<< @

	change-state: ~> 
		currentValue = @runtime.get('help-state')
		unless currentValue + it < 0 or currentValue + it >= @articles.length
			currentValue += it
			@runtime.set('help-state', currentValue)
			
	verify-state: ~>
		if ( it.target.className.indexOf "wrapper" ) >= 0 then @runtime.set("app-state", 1)

Controller = new HelpController()
angular.module AppInfo.displayname .controller "Help", ["$scope", "Runtime", Controller.init]
module.exports = Controller
