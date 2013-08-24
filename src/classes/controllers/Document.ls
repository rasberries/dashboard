const STATES = [\outline \mindmap]; States = new IS.Enum STATES
const AUXSTATES = [\sidebaropen \sidebarclosed]; Aux-states = new IS.Enum AUXSTATES

angular.module AppInfo.displayname .directive "ngcFocus", [\$parse, ($parse) ->
	(scope, element, attr) -> 
		fn = $parse attr['ngcFocus']
		element.bind \focus, (e) ->
			scope.$apply -> fn scope, {$event: e}
]

class DocumentController extends IS.Object
	~>
		@log "Document Controller Online"
		window.DocumentController = @
		@STATES = STATES; @States = States
		@AUXSTATES = STATES; @AuxStates = AuxStates
		@render-document-template!
		Client?.events = 
			"node.change": (...args) ~> @passthrough @node-change, args
			"node.add": @node-add
			"node.add-root": @node-add-root
			"node.remove": @node-remove
			"node.move": @node-move
		Client?.loadEvents!

	node-change: (index, property, value) ~>
		@log "Changing #{index}'s #{property} to #{value}"
		node = @fetch-node index
		node[property] = value
		if property is \status then @propagate-change node
		if property is \text then node.$renderer.sequence!
		if property is \relation then node.$linerenderer?.sequence!
		@fetch-document!.refresh!
		node.$renderer.sequence!
		@safeApply!

	node-move: (index, x, y) ~>
		node = @fetch-node index
		node.location.x = x
		node.location.y = y
		node.$linerenderer?.sequence!
		if node.children then for kid in node.children
			kid.$linerenderer.sequence!

	replicate: (node, property) ~> @prep 'node.change', node.$index, property, node[property]
	add: (node) ~> Client.publish 'node.add', node.$index
	add-root: ~> Client.publish "node.add-root", null
	remove: (node) ~> Client.publish 'node.remove', node.$index
	fetch-document: ~>  @models._reccords[@runtime.props['active-document']]
	fetch-node: (index) ~> @fetch-document!.indexes[index]

	node-add: (index) ~>
		@log index, @fetch-node index
		node = @fetch-node index
		node.children ?= []
		node.children.push {text: "New Node"}
		node.status = \indeterminate
		@fetch-document!.refresh!
		@safe-apply!
		setTimeout LanguageHelper._translateAll, 50

	node-add-root: ~> 
		doc = @fetch-document!
		if doc then
			@log doc.data
			doc.data.push text: "New Root Document"
			@log doc.data
			doc.refresh!
			@safe-apply!
			setTimeout LanguageHelper._translateAll, 50
		else @models.new!
		@safe-apply!

	node-remove: (index) ~>
		node = @fetch-node index
		repo = node.$parent.children or node.$parent.data
		repo.splice repo.indexOf node, 1
		if repo.length is 0 and node.$parent.children
			node.$parent.children = null
			node.$parent.status = \unchecked
		@fetch-document!.refresh!
		@safe-apply!


	passthrough: (fn, args) ~>
		id = args.pop!
		if id isnt Client.id then fn.apply @, args

	prep: (ev, ...data) ~>
		data.push Client.id
		data.unshift ev
		Client.publish.apply Client, data 

	render-document-template: ~>
		div = document.create-element "div"
		div.setAttribute "rel", "Main Document Placeholder"
		div.setAttribute "id", "documentplaceholder"
		div.innerHTML = DepMan.render [\document \index], {Aux-states}
		$ div .insertBefore ($ 'section#application' .children![0])

	init-runtime: ~>
		@runtime.init "document-state", \number
		@runtime.subscribe "prop-document-state-change", ~> @safe-apply!
		@runtime.subscribe "prop-document-state-change", ~> 
			if @runtime.props['document-state'] is States.outline then @canvas.end!; @scanvas.end!
			else @canvas.start!; @scanvas.start!


	init: (@scope, @runtime, @models, @canvas, @scanvas) ~>
		@config-scope!
		@init-runtime!
		@hook-keyboard!
		@hook-gestures!
		@runtime.subscribe 'prop-active-document-change', @get-active-document
		@get-active-document!

	hook-keyboard: ~>
		key = if Tester.mac then "cmd" else "ctrl"
		handle = (e, way = null) ~>
			unless @runtime.props[\app-state] isnt 1
				e.preventDefault!
				if way then @runtime.set "document-state", States[way]
				else if @runtime.props[\document-state] is States.outline then @runtime.set \document-state, States.mindmap
				else @runtime.set \document-state, States.outline
		jwerty.key "#{key}+]", ~> handle it, \mindmap
		jwerty.key "#{key}+[", ~> handle it, \outline
		jwerty.key "#{key}+alt+tab", ~> handle it

	hook-gestures: ~>
		target = Hammer ($ '#documentplaceholder #outline' .0)
		target.on "swipeleft", ~> @runtime.set 'document-state', States.mindmap
		target.on "swiperight", ~> @runtime.set 'sidebar-state', 1
		target.on "tap", ~> @runtime.set 'sidebar-state', 0
		@log target

	config-scope: ~>
		@safeApply = (fn) ~>
			phase = @scope.$parent.$$phase
			if phase is "$apply" or phase is "$digest"
				if fn and (typeof(fn) is 'function')
					do fn
			else @scope.$apply(fn)
			LanguageHelper._translateAll!
		@scope <<< @
		@canvas.edit = @modal-edit
		@canvas.new-root = @add-root

	switch: (id) ~> @runtime.set 'active-document', id

	get-active-document: ~> 
		@scope.active-document = @models._reccords[@runtime.get 'active-document']
		@runtime.set 'document-state', States.mindmap
		@safeApply!

	get-styles: (node) ~>
		size = 50; if window.innerWidth <= 320 then size = 15
		padding-left: node.$depth * size

	change-status: (node, preventBubble = false) ~>
		oldstatus = node.status
		let @ = node
			if @children and @children.length > 0
				det = 0
				for kid in @children
					if kid.status in [\checked \determinate] then det++
				if det is @children.length then @status = \determinate
				else @status = \indeterminate
			else 
				if @$status then @status = \checked
				else @status = \unchecked
		unless node.status is oldstatus
			node.$renderer.sequence!
			unless preventBubble
				@replicate node, \status
				@propagate-change node
				@safeApply!

	propagate-change: (node) ~>
		while node
			if node.$parent then node = node.$parent
			else break
			@change-status node, true
		@safeApply!

	refresh: (node) ~> @replicate node, '$folded'; @fetch-document!.refresh!
	modal-edit: (node) ~>
		sub = @runtime.subscribe \prop-modal-state-change, ~>
			unless @runtime.props[\modal-state] isnt 0
				form = $ '#editform'
				oldvalues = 
					text: node.text
					relation: node.relation
					note: node.note
					folded: node.$folded
					checked: node.$status
				node.text = form.find '#text' .val!
				node.relation = form.find '#relation' .val!
				node.note = form.find '#note' .val!
				if node.children? and node.children.length >= 0
					node.$folded = (form.find '#folded' .0.checked) is true
				else node.$status = (form.find '#checked' .0.checked) is true
				if oldvalues.text isnt node.text then @replicate node, 'text'; node.$renderer.sequence!
				if oldvalues.relation isnt node.relation then node.$linerenderer?.sequence!; @replicate node, 'relation'
				if oldvalues.note isnt node.note then @replicate node, 'note'
				if oldvalues.$folded isnt node.$folded then @refresh node
				if oldvalues.checked isnt node.$status then @change-status node
				@runtime.unsubscribe \prop-modal-state-change, sub
				@safeApply!
		Modal.show title: "Edit node", content: DepMan.render [\document \editform]
		setTimeout ~>
			form = $ '#editform'
			if window.innerWidth <= 300 then @runtime.set 'modal-state', 2
			form.find '#checkcontainer' .attr "checked", false .show!
			form.find '#foldcontainer' .attr "checked", false .show! 
			form.find '#text' .val node.text
			form.find '#relation' .val node.relation
			form.find '#note' .val node.note
			if node.children? and node.children.length >= 0 
				form.find '#checkcontainer' .hide!
				form.find '#folded' .attr 'checked', true if node.$folded
			else 
				form.find '#foldcontainer' .hide!
				form.find '#checked' .attr 'checked', true if node.$status
			form.find '#addnode' .click ~> 
				@add node
				@runtime.unsubscribe \prop-modal-state-change, sub
				form.find '#addnode' .unbind!
				Modal.hide!
				@safeApply!
			form.find '#removenode' .click ~>
				@remove node
				@runtime.unsubscribe \prop-modal-state-change, sub
				form.find '#removenode' .unbind!
				Modal.hide!
				@safeApply!
		, 50


Controller = new DocumentController()
angular.module AppInfo.displayname .controller "Document", ["$scope", "Runtime", "Documents", "Canvas", "ShadowCanvas", Controller.init]
module.exports = Controller
