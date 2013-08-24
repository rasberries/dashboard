class DocumentListController extends IS.Object
	~>
		@log "DocumentList Controller Online"
		window.DocumentListController = @
		@render-list-template!

	render-list-template: ~>
		div = document.create-element "div"
		div.setAttribute "rel", "Documents List Placeholder"
		div.setAttribute "id", "documentlistplaceholder"
		div.innerHTML = DepMan.render [\document \list]
		$ '#sidebar-container section section' .children()[0] .appendChild div

	init: (@scope, @runtime, @models, @dnd) ~>
		@config-scope!
		@hook-keyboard!
		@hook-events!

	hook-events: ~>
		Client?.events = 
			"connection.new": @connection-new
			"connection.request": @connection-request
			"connection.broadcast": @connection-broadcast
			"document.change": (...args) ~> @passthrough @document-change, args
		Client?.loadEvents
		@runtime.subscribe "prop-active-document-change", @save-state

	replicate: ~> @prep 'document.change', @fetch-document!.title
	document-change: (newval) ~> @fetch-document!.title = newval; @safeApply!

	passthrough: (fn, args) ~>
		id = args.pop!
		if id isnt Client.id then fn.apply @, args

	prep: (ev, ...data) ~>
		data.push Client.id
		data.unshift ev
		Client.publish.apply Client, data  

	connection-request: ~> @requested = true; @log "Client connect requested! (should not send away data)"

	connection-new: (id) ~> 
		unless @requested
			@log "Sending data to the new connection! (should not appear on the requester)"
			Client.publish "connection.broadcast", id, @fetch-document!.export!

	connection-broadcast: (id, doc) ~>
		if not id? or id is Client.id
			@log "Got data from the connectee! (should appear on the requester)"
			Toast "Got Document", "Got incoming document from the network!", "The new document has been opened and synchronized between all clients!"
			@models.get-document doc
			delete @requested

	hook-keyboard: ~>
		key = if Tester.mac then "cmd" else "ctrl"
		handle = (e, key) ~>
			e.preventDefault!
			switch key
			| \new => @add-document!
			| \next, \previous => 
				return if @runtime.props['sidebar-state'] is 0 or @runtime.props['sidebar-tab'] isnt 0
				current = @models.documents.indexOf @runtime.props['active-document']
				if key is \next and current + 1 < @models.documents.length then current += 1
				if key is \previous and current - 1 > 0 then current -= 1
				@runtime.set 'active-document', @models.documents[current]
			| otherwise =>
				if @["#{key}Document"] then @["#{key}Document"]!
 
		jwerty.key "#{key}+alt+n", ~> @log "N"; handle it, \new
		jwerty.key "#{key}+arrow-down", ~> handle it, \next
		jwerty.key "#{key}+arrow-up", ~> handle it, \previous
		jwerty.key "#{key}+s", ~> handle it, \save
		jwerty.key "#{key}+d", ~> handle it, \delete
		jwerty.key "#{key}+shift+d", ~> handle it, \download
		jwerty.key "#{key}+shift+u", ~> handle it, \upload
		jwerty.key "#{key}+shift+c", ~> handle it, \duplicate
		@log "Handled!"

	config-scope: ~>
		@safeApply = (fn) ~>
			phase = @scope.$parent.$$phase
			if phase is "$apply" or phase is "$digest"
				if fn and (typeof(fn) is 'function')
					do fn
			else @scope.$apply(fn)
		@scope <<< @

	switch: ~> 
		unless @runtime.props['active-document'] is it
			@runtime.set 'active-document', it
			Client.publish "connection.broadcast", null, @fetch-document!.export!
	add-document: ~> @models.new!; Client.publish "connection.broadcast", null, @fetch-document!.export!
	delete-document: ~> @models.delete @runtime.props['active-document'] 
	save-document: (doc) ~> @models.save (doc or @runtime.props['active-document'])
	download-document: ~> 
		content = @fetch-document!.export()
		window.open "data:application/xml,#content", "Download", "location=no,menubar=no,titlebar=no,toolbar=no"
	fetch-document: ~>  @models._reccords[@runtime.props['active-document']]
	duplicate-document: ~>
		doc = @fetch-document!
		content = doc.export()
		content = content.replace doc.title, "#{doc.title} Copy"
		[f, l] = [(content.indexOf "<uuid>"), (content.indexOf "</uuid>")]
		content = content.replace (content.substr f, l - f + 9), ""
		@models.get-document content
	save-state: ~> 
		for doc in @models.documents
			@save-document doc
	upload-document: ~>
		input = document.create-element "input"
		input.type = 'file'
		document.body.append-child input
		$ input .click!change ~>
			for file in it.target.files then let f = file
				type = f.name.substr ( f.name.lastIndexOf "." ) + 1 
				if type in [\opml \xml]
					reader = new FileReader!
					reader.onload = ~> @models.get-document it.target.result
					reader.read-as-text f

Controller = new DocumentListController()
angular.module AppInfo.displayname .controller "DocumentList", ["$scope", "Runtime", "Documents", "DND", Controller.init]
module.exports = Controller
