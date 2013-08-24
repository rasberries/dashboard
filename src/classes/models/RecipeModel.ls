__dummy-data__ = 
		"NPM": {
			name: "NPM", description: "Install NPM", author: "sabinmarcu@gmail.com", stubs: [
				{ url: "http://npmjs.org/install.sh", instructions: [
					"sh install.sh"
				] }
			]
		}
		"Node": {
			name: "Node", description: "Install Node.JS", author: "sabinmarcu@gmail.com", stubs: [
				{ url: "http://nodejs.org/install.tar.gz", instructions: [
					{ command: "tar -xvzf install.tar.gz" }
					{ command: "cd install" }
					{ command: "./configure" }
					{ command: "make" }
					{ command: "make install" }
				] }
				{ url: "sabinmarcu@gmail.com/NPM", instructions: [] }
			]
		}

__dummy-list__ = <[NPM Node]>
__blank-data__ = 
	description: "something", stubs: []

class RecipeModel extends IS.Object
	@extend IS.Modules.ORM
	@init = (@list = __dummy-list__) ~>
		window.RecipeRepo = @;  @_reccords = {}; @controller?.recipes = @_reccords
		for item in @list then let i = item
			x = @reuse i, __blank-data__; x._id = i

	init: (@data) ~> @data.name = @_id

	edit: (something, into) ~>
		unless not @data[something]
			@data[something] = into
			@send something

	send: (something) ~>
		@log "Should send '#something' [#{@data[something]}]"

	get-data: ~>
		@data = __dummy-data__[@_id] or @data
		@log "Should get them online"

	@new = ~> x = @reuse "New Recipe", __blank-data__; x._id = "New Recipe"

RecipeModel.init!
angular.module AppInfo.displayname .factory "Recipe", -> RecipeModel