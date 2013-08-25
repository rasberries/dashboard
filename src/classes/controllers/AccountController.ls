class AccountController extends IS.Object
	(@scope, @runtime, @user) ~> @get-model!config-scope!hook-events!

	config-scope: ~>
		@safeApply = (fn) ~>
			phase = @scope.$parent.$$phase
			if phase is "$apply" or phase is "$digest"
				if fn and (typeof(fn) is 'function')
					do fn
			else @scope.$apply(fn)
		@scope <<< @
		@

	get-model: ~> @

	hook-events: ~>
		$ '#account-name' .change ~> @user.send \name
		$ '#account-email' .change ~> if @user.verify-email! then @user.send \email

	change-password: ~>
		if (@user.verify-password @scope.currentpass) and @verify-new-passwords!
			@user.edit \password, @scope.newpass
			Toast "Success", "Data is saved!"
		else Toast "Error", "Data was not saved! (check console for logs)"
		@scope.currentpass = @scope.newpass = @scope.newpassverify = ""

	verify-new-passwords: ~> @scope.newpass is @scope.newpassverify

angular.module AppInfo.displayname .controller "AccountController", ["$scope", "Runtime", "User", AccountController]