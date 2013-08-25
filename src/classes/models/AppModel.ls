__blank-data__ = 
	description: "something", stubs: []

class RecipeModel extends IS.Object
	@extend IS.Modules.ORM
	@init = (@runtime) ~> 
		window.RecipeRepo = @
		@runtime.subscribe "prop-active-tab-change", ~> if @runtime.props['active-tab'] is 3 then @refresh!
		@runtime.subscribe "prop-app-state-change", ~> if @runtime.props['app-state'] is 1 then @refresh!
		@refresh!
		@

	@refresh = ~>
		onsuccess = (@list) ~>
			@log @list
			@_reccords = {}; @controller?.recipes = @_reccords
			for item in @list then let i = item
				if i._id then delete i._id
				x = @create i.name, item
				x._id = i.name
				x.data.stubs ?= []
			@log @controller
			@controller?.safeApply!
		onerror = -> Toast "Error", "Could not get the list of stuff!"
		unless not UserModel? or not UserModel.data? or not UserModel.data.mail?
			Client.request "users/#{UserModel.data.mail}/apps", onsuccess, onerror

	init: (@data) ~> @data.name = @_id

	edit: (something, into) ~>
		unless not @data[something]
			@data[something] = into
			@send something

	send: (something) ~>
		@log "Should send '#something' [#{@data[something]}]"

	get-data: ~>
		onsuccess = (@data) ~>
		onerror = ~> Toast "Error", "Could not get the full recipe!"
		unless not UserModel? or not UserModel.data? or not UserModel.data.mail?
			Client.request "apps/#{@data.id}", onsuccess, onerror

	save: ~>
		onsuccess = ~> Toast "Success", "The data was saved!"
		onerror = ~> Toast "Error", "Could not save the data!"
		unless not UserModel? or not UserModel.data? or not UserModel.data.mail?
			data = {}; data <<< @data; data.author = UserModel.data.mail; data.id = "#{UserModel.data.mail}:#{data.name}"
			if data._id then delete data._id
			Client.post "apps/update/", data, onsuccess, onerror

	@new = ~> x = @reuse "New Recipe", __blank-data__; x._id = "New Recipe"

angular.module AppInfo.displayname .factory "Recipe", ["Runtime", RecipeModel.init]