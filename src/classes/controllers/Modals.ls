const STATES = [\closed \normal \fullscreen]; States = new IS.Enum STATES

class ModalController extends IS.Object
	~>
		@set-attributes!
		@render-modal!
	render-modal: ~>
		div = document.createElement \div
		div.innerHTML = DepMan.render "modal", { States, STATES }
		div.setAttribute 'rel', "Modal Container"
		div.setAttribute \id, \modal-container
		document.body.appendChild div
	set-attributes: ~>
		@title = "Modal Window"
		@content = "Test Content"
	init: (@scope, @runtime) ~> 
		@config-scope!
		@init-runtime!
		@hook-keyboard!
	hook-keyboard: ~>
		jwerty.key "esc", ~> @hide!
	config-scope: ~>
		@safeApply = (fn) ~>
			phase = @scope.$parent.$$phase
			if phase is "$apply" or phase is "$digest"
				if fn and (typeof(fn) is 'function')
					do fn
			else @scope.$apply(fn)
		@scope <<< @
	init-runtime: ~>
		@runtime.init 'modal-state', \number
		
	toggle: ~>
		if ( @runtime.get \modal-state ) is States.normal then @runtime.set \modal-state, States.fullscreen
		else @runtime.set \modal-state, States.normal
		@log @runtime.get \modal-state

	show: (data = {title: "No Title", content: "No Content"}, timeout) ~>
		@scope.title = data.title or @scope.title
		@scope.content = data.content or @scope.content
		if window.innerWidth <= 320 then @runtime.set \modal-state, States.fullscreen
		else @runtime.set \modal-state, States.normal
		if timeout then setTimeout @hide, timeout
		@safeApply!
	hide: ~> @runtime.set \modal-state, States.closed; @safeApply!
	set: (key, value) ~> if key in [\title \content] then @[key] = value; @safeApply!

Controller = new ModalController()
angular.module AppInfo.displayname .controller "Modal", ["$scope", "Runtime", Controller.init]
window.Modal = 
	set: -> Controller.edit.apply Controller, arguments
	show: -> Controller.show.apply Controller, arguments
	hide: -> Controller.hide.apply Controller, arguments
module.exports = Controller
