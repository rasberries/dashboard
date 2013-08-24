class OPMLReader extends IS.Object
	(@data) ~>
		@json = []
		@opml = ""
		if @data.substr? then @decode-opml!
		else @encode-json!

	encode-json: ~> 
		@json = @data
		@uuid = @data.uuid
		@title = @data.title
		[body, expansionState] = @encode-node @json.data
		@opml = """<?xml version='1.0' encoding='utf-8' ?>
			<opml>
				<head>
					<title>#{@data.title}</title>
					<expansionState>#expansionState</expansionState>
					<uuid>#{@data.uuid}</uuid>
				</head>
				<body>
		#body
				</body>
			</opml>
		"""
	encode-node: (list, depth = 3) ~>
		@log "Encoding [#depth]", list
		@index ?= 0
		expansionState = []
		finalstring = ""
		const tabs = new Array(depth + 1) * "\t"
		for node in list
			string = "#tabs<outline "
			for key, value of node 
				unless key in [ \children \text ] or key[0] is '$' 
					if key is \location then value = "#{value.x},#{value.y}"
					string += "_#key='#value' "
				if key is \text then string += "#key='#value' "
			@index += 1
			if node.$folded then expansionState.push @index
			if node.children?
				nextState = []
				nextString = ""
				string += ">\n"
				[nextString, nextState] = @encode-node node.children, depth + 1
				string += nextString
				expansionState = expansionState ++ nextState
				string += "#tabs</outline>\n"
			else string += "/>\n"
			finalstring += string
		[ finalstring, expansionState ]

	decode-opml: ~>
		@opml = @data
		@dom = ( new DOMParser() ).parseFromString @opml, "text/xml" .childNodes[0]
		@index = 0
		@expansionState = []
		if (node = @find-opml-node @dom .querySelector "expansionState") and node?
			@expansionState = JSON.parse [ \[, node.childNodes[0]?.nodeValue, \] ] * ""
		@uuid = null
		if (node = @find-opml-node @dom .querySelector "uuid") and node?
			@uuid = node.childNodes[0]?.nodeValue
		@json =
			title: @find-opml-node @dom .querySelector "title" .childNodes[0].nodeValue
			data: @decode-list (@find-opml-node @dom, 2 .childNodes)
		@title = @json.title
		@log @

	decode-list: (list) ~>
		l = []
		for item in list when @validate-opml-node item
			@log "Extracting", item
			@index += 1
			i = {}
			if @index in @expansionState then i.$folded = true
			for attr in item.attributes
				name = attr.nodeName
				if name[0] is "_" then name = name.substr 1
				if name is "location" 
					val = JSON.parse "[#{attr.nodeValue}]"
					i[name] = x: val[0], y: val[1]
				else i[name] = attr.nodeValue
			if item.childNodes.length
				i.children = @decode-list item.childNodes
			l.push i
		l

	find-opml-node: (item, which = 1) ~>
		nr = 0
		for node in item.childNodes
			if @validate-opml-node node
				nr++
				if nr is which then return node
		return null

	validate-opml-node: (node) ~> node.nodeName isnt '#text'


class OPMLAPI extends IS.Object
	~> @log "OPML API Online!"; window.OPML = @
	read: (data) ~> new OPMLReader data

angular.module AppInfo.displayname .service \OPMLReader, OPMLAPI
