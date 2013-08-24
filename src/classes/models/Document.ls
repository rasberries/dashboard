class DocumentModel extends IS.Object

	@extend IS.Modules.ORM
	
	init: (data) ~> 
		@data = data.element
		@parent = @constructor
		@title = @data.title
		@_id = @_uuid
		if @data.uuid then @parent.relocate @_uuid, @data.uuid
		else @_id = @_uuid
		@data = @data.json.data
		@parent.documents.push @_id
		@refresh!
		@parent.runtime.set "active-document", @_id
		@log "New Document: [#{@title}|#{@_id}]"

	refresh: ~> 
		@initIndex!
		@refreshIndex @data, 0, @
	initIndex: ~>
		@index = 0
		@indexes = []
		@levels = []
	refreshIndex: (list, depth, parent) ~>
		@levels[depth] ?= []
		for node in list
			node.$index = @index++
			node.$depth = depth
			node.$parent = parent
			node.$status ?= false
			node.$viewmore ?= false
			node.$folded ?= false
			node.$hidden = parent.$folded
			node.relation ?= ""
			node.note ?= ""
			if not node.status
				if node.children and node.children.length then node.status = "indeterminate"
				else node.status = "unchecked"
			if not node.$renderer then node.$renderer = new (DepMan.renderer "Node")(node)
			if not node.location
				y-offset = @levels[depth].length
				if y-offset then y-offset = @levels[depth][y-offset - 1].location.y + 70
				if parent.location then node.location = x: parent.location.x + 350, y: parent.location.y + y-offset
				else node.location = x: 20, y: 20 + y-offset
			if depth and not node.$linerenderer then node.$linerenderer  =  new (DepMan.renderer "Line")(node)
			@indexes.push node
			@levels[depth].push node
			if node.children then @refreshIndex node.children, depth + 1, node
	save: ~> @parent.save @_id
	delete: ~> @parent.delete @_id
	export: ~> @log @; (@parent.reader.read title: @title, data: @data, uuid: @_id).opml

	@inject = (@runtime, @reader) ~> 
		@documents = []
		@get-initial-state!
		@

	@relocate = (init, final) ~> 
		@log "Relocating #{init} to #{final}"
		@_reccords[final] = @_reccords[init]
		@documents.splice @documents.indexOf init, 1, final
		if @runtime.props['active-document'] is init then @runtime.set 'active-document', final
		delete @_reccords[init]
		@_reccords[final]._id = @_reccords[final]._uuid = final

	@get-initial-state = ~>
		docs <~ DBStorage.get "documents"
		docs ?= []
		if docs.substr? then docs = JSON.parse docs
		for doc in docs
			content <~ DBStorage.get doc
			@get-document content

	@get-document = (data) ~> 
		data = @reader.read data
		kid = @reuse null, element: data
		kid

	@new = ~> 
		@get-document title: "New Document", data: [
			{text: "Parent Node", children: [
				{text: "Child Node"}, {text: "Second Child Node"}
			]}
			{text: "Sibling"}
		]	

	@delete = (item) ~>
		@deleteLink item
		delete @_reccords[item]
		DBStorage.remove item
		index = @documents.indexOf item
		@documents = @documents.splice index, 1
		@runtime.set 'active-document', @documents[index-1] or null
		Toast "Document Status", "The document has been successfuly deleted!"

	@deleteLink = (item) ~>
		items <~ DBStorage.get "documents"
		items ?= []
		if items.substr? then items = JSON.parse items
		if items.indexOf item >= 0
			items.splice (items.indexOf item), 1
			DBStorage.set "documents", JSON.stringify items

	@save = (item) ~>
		@saveLink item
		DBStorage.set item, @_reccords[item].export! if @_reccords[item]
		Toast "Document Status", "The document has been successfuly saved!"

	@saveLink = (item) ~>
		items <~ DBStorage.get "documents"
		items ?= []
		if items.substr? then items = JSON.parse items
		unless (items.indexOf item) >= 0
			items.push item
			DBStorage.set "documents", JSON.stringify items



angular.module AppInfo.displayname .factory \Documents, [ "Runtime", \OPMLReader, DocumentModel.inject ]
module.exports = window.Documents = DocumentModel
