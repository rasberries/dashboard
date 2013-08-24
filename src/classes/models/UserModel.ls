class UserModel extends IS.Object
	~> 
		window.UserModel = @
		form = $ '#login-form'
		login-func = ~>
			data = mail: form.find '#login-email' .val!, pass: form.find '#login-password' .val!
			if (data.mail isnt "") and (data.pass isnt "") 
				Client.login data, ~>
					@data = data
					form.find '#login-email' .val ""
					form.find '#login-password' .val ""
		form.find '#submit-button' .click login-func
		form.find '#login-email' .change login-func
		form.find '#login-password' .change login-func

	edit: (something, into) ~>
		unless not @data? or not @data[something]
			@data[something] = into
			@send something
	send: (something) ~>
		@log "Should send '#something' [#{@data[something]}]"

	verify-password: ~> it is @data.password
	verify-email: ~> /^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$/.test @data.email

angular.module AppInfo.displayname .value "User", UserModel