class ApplicationsController extends IS.Object
	(@scope, @runtime, @recipe-model, @user) ~> @get-model!config-scope!

	config-scope: ~>
		@info = device: null
		@safeApply = (fn) ~>
			phase = @scope.$parent.$$phase
			if phase is "$apply" or phase is "$digest"
				if fn and (typeof(fn) is 'function')
					do fn
			else @scope.$apply(fn)
		@scope <<< @
		@

	get-model: ~> @recipe-model.controller = @; @
	install-app: (recipe) ~> 
		Client.post "devices/stack_app", (uuid: @info.device.uuid, app_id: "#{UserModel.data.mail}$#{recipe._id}"), (-> Toast "Success", "App queued to install on device"), (-> Toast "Error", "Failed to queue app for install")
		@info.device = null

angular.module AppInfo.displayname .controller "ApplicationsController", ["$scope", "Runtime", "Recipe", "User", ApplicationsController]