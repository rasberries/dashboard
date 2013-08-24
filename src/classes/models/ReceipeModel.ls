__dummy-data__ = 
	[
		{
			name: "NPM", description: "Install NPM", stubs: [
				{ url: "http://npmjs.org/install.sh", instructions: [
					"sh install.sh"
				] }
			]
		}
		{
			name: "Node", description: "Install Node.JS", stubs: [
				{ url: "http://nodejs.org/install.tar.gz", instructions: [
					"tar -xvzf install.tar.gz"
					"cd install"
					"./configure"
					"make"
					"make install"
				] }
				{ url: "http://npmjs.org/install.sh", instructions: [
					"sh install.sh" 
				] }
			]
		}
	]

class RecipeModel extends IS.Object
	@extend IS.Modules.ORM
	@init = (@data = __dummy-data__) ~>
		window.RecipeRepo = @
		delete @_reccords; @_reccords = {}
		for item in @data
			@reuse null, item

	init: (@data) ~> 
		@log "Should go for the remote data"

	edit: (something, into) ~>
		unless not @data[something]
			@data[something] = into
			@send something

	send: (something) ~>
		@log "Should send '#something' [#{@data[something]}]"

	verify-password: ~> it is @data.password
	verify-email: ~> /^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$/.test @data.email

RecipeModel.init!
angular.module AppInfo.displayname .factory "Recipe", -> RecipeModel