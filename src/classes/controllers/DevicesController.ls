class DevicesController extends IS.Object
	(@scope, @runtime, @recipe-model, @user) ~> @get-model!config-scope!hook-events!

	config-scope: ~>
		@safeApply = (fn) ~>
			phase = @scope.$parent.$$phase
			if phase is "$apply" or phase is "$digest"
				if fn and (typeof(fn) is 'function')
					do fn
			else @scope.$apply(fn)
		@scope <<< @
		@

	get-model: ~> @recipe-model.controller = @; @
	update: (device) ~> Client.post "devices/register", mail: device.mail, uuid: device.uuid, name: device.name
	hook-events: ~>

angular.module AppInfo.displayname .controller "DevicesController", ["$scope", "Runtime", "Recipe", "User", DevicesController]