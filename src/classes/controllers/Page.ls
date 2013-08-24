const STATES = [\landing \application \help]; States = new IS.Enum STATES
const MODALS = [\modal-inactive \modal-active \modal-active]; Modals = new IS.Enum MODALS

class PageController extends IS.Object
	# First time setup
	~>
		@set-attributes!
		@render-index!
		@log "PageController Initialized"

	set-attributes: ~>
		document.body.setAttribute "ng-csp", true
		document.body.setAttribute "ng-controller", "Page"
		window.PageController = @

	# Initialization stuff
	init: (@scope, @runtime) ~>
		# Bootstrapping the scope and other variables
		@config-scope!
		@init-runtime!
		@get-stored!
		@hook-keyboard!
		@

	hook-keyboard: ~>
		key = if Tester.mac then "cmd" else "ctrl"
		handler = (e, key) ~>
			if UserModel.data?
				e.preventDefault!
				key = switch key
				| \l => States.landing
				| \p => States.application
				| \? => States.help
				@runtime.set \app-state key
				@safeApply!
		jwerty.key "#{key}+l", ~> handler it, \l
		jwerty.key "#{key}+p", ~> handler it, \p
		jwerty.key "#{key}+shift+/", ~> handler it, \?
		jwerty.key "esc", ~> if (@runtime.get \app-state) is States.help then @runtime.set \app-state, States.application; @safeApply! 

	render-index: ~>
		d = document.createElement "div"
		d.setAttribute "id", "appwrapper"
		d.setAttribute "class", "{{computeClass()}}"
		d.setAttribute "rel", "Document Wrapper"
		d.innerHTML = DepMan.render "index", {States}
		document.body.insertBefore d, document.body.children[0]
		
	config-scope: ~>
		@safeApply = (fn) ~>
			phase = @scope.$parent.$$phase
			if phase is "$apply" or phase is "$digest"
				if fn and (typeof(fn) is 'function')
					do fn
			else @scope.$apply(fn)
		@scope <<< @
	init-runtime: ~> @runtime.init "app-state", \number
	get-stored: ~>
		@prev-state = States[\landing]
		DBStorage.get "app-state", (state) ~>
			@prev-state = (parseInt state) or States[\landing]
			@runtime.set "app-state", @prev-state
			@safeApply!
		@runtime.subscribe "prop-app-state-change", (value) ~>
			switch value
			| States[\landing] => DBStorage.set "app-state", States[\landing]; @log "State changed, switching to landing next time!"
			| otherwise =>
				if @prev-state is States[\landing]
					DBStorage.set "app-state", States[\application]
					@log "State changed, switching to app next time!"
			@prev-state = value

	# Finally, the stuff connected with the scope (angular magic)
	get-body-state: ~> STATES[@runtime.get "app-state"]
	compute-class: ~> [STATES[@runtime.get('app-state')], MODALS[@runtime.get("modal-state")]] * " "


# Bootstrapping the whole shebang!
Controller = new PageController()
angular.module AppInfo.displayname .controller "Page", ["$scope", "Runtime", Controller.init]
module.exports = Controller
