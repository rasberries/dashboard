class UserModel extends IS.Object
	(@runtime) ~> 
		window.UserModel = @

		form = $ '#login-form'
		login-func = ~>
			data = mail: form.find '#login-email' .val!, pass: form.find '#login-password' .val!
			if (data.mail isnt "") and (data.pass isnt "") 
				Client.login data, ~>
					@data = data
					@runtime.set 'app-state', 1
					form.find '#login-email' .val ""
					form.find '#login-password' .val ""
					onsuccess = (list) ~> 
						@data.devices = list[0].user_devices.filter (e, pos, self) -> (self.indexOf e) is pos
						@devices = {}
						for device in @data.devices then let d = device
							Client.request "devices/#d", (~> @devices[d] = it), (-> Toast "Error", "Could not get info about #d device")
					onerror = -> Toast "Error", "Could not grab the devices list."
					Client.request "users/devices/#{@data.mail}", onsuccess, onerror

		regform = $ '#register-form'
		register-func = ~>
			data = mail: regform.find '#register-email' .val!, pass: regform.find '#register-pass' .val!, verpass: regform.find '#register-pass-verify' .val!
			@log data
			if (data.mail isnt "") and (data.pass isnt "") and (data.verpass isnt "")
				if data.pass isnt data.verpass then Toast "Error", "The two passwords were different"
				else 
					Client.register data, ~>
						regform.find '#register-email' .val ""
						regform.find '#register-pass' .val ""
						regform.find '#register-pass-verify' .val ""

		form.find '#submit-button' .click login-func
		form.find '#login-email' .change login-func
		form.find '#login-password' .change login-func

		regform.find '#submit-button' .click register-func
		regform.find '#register-email' .change register-func
		regform.find '#register-pass' .change register-func
		regform.find '#register-pass-verify' .change register-func

		@


	edit: (something, into) ~>
		unless not @data? or not @data[something]
			@data[something] = into
			@send something

	send: (something) ~>
		@log "Should send '#something' [#{@data[something]}]"

	verify-password: ~> it is @data.password
	verify-email: ~> /^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$/.test @data.email

angular.module AppInfo.displayname .service "User", [ "Runtime", UserModel ]