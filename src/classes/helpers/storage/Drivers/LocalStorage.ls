class LocalStorageDriver extends IS.Object
	~> @log @; it!
	set: (item, value) ~>
		switch typeof value
		| "object" => @set-object item, value
		| "function" => @set item, value!
		| otherwise => @set-string item, value
	set-object: (item, object)~>
		props = [key for key, value of object]
		@set-string item, "#>object#{item}"
		@set-string "#>object#{item}-props", JSON.stringify props
		for prop in props
			@set "#>object#{item}-prop-#{prop}", object[prop]
	get: (item, callback) ~>
		set <~ @get-string item
		init = set[item]
		return callback null unless init
		if ( init.substr 0, 2 ) is \#> then @get-object init, callback
		else callback init		
	get-object: (item, callback) ->
		object = {}
		<~ @handle-object item, \get, object
		callback object
	handle-object: (item, func, object, callback) ~>
		propsstring = "#{item}-props"
		set <~ @get-string propsstring
		props = JSON.parse set[propsstring]
		[tick, length] = [0, props.length]

		for prop in props then let p = prop
			propstring = "#{item}-prop-#{prop}"
			f = switch func
			| \get => @get
			| otherwise => @remove
			h = switch func
			| \get => ~> object[p] = it
			| otherwise => ~> @remove-string propstring
			do ~> f propstring, h; tick++

		int = setInterval ~>
			if tick is length
				clearInterval int
				callback! if callback?
		, 5
		
	remove: (item) ~>
		set <~ @get-string item
		init = set[item]
		if ( init.substr 0, 2 ) is \#> then @remove-object init
		@remove-string item
		@remove-string "#>object#{item}-props"
	remove-object: (item) ~>
		<~ @handle-object item, \remove

	#The default string functions
	set-string: LocalStorage.set
	get-string: LocalStorage.get
	remove-string: LocalStorage.remove

module.exports = LocalStorageDriver
