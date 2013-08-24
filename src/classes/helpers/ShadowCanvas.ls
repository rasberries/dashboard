class ShadowCanvasService extends DepMan.renderer "Base" 
	(@runtime, @documents) ~> 
		@log "ShadowCanvasService initialized"
		super!
		window.addEventListener \resize, @resize
		@resize!

	resize: ~>
		@buffer.width = window.innerWidth
		@buffer.height = window.innerHeight - 49

	sequence: ~>
		doc = @documents._reccords[@runtime.props['active-document']]
		if doc 
			@reset!
			if @offsets? then @context.translate @offsets.x, @offsets.y
			# One pass, shadow nodes.
			for node in doc.indexes when node.$hidden isnt true
				unless node.$renderer.drawing
					@context.drawImage node.$renderer.sbuffer, node.location.x, node.location.y

			if @functional then requestAnimationFrame @sequence

	start: ~> @functional = true; requestAnimationFrame @sequence
	end: ~> delete @functional


angular.module AppInfo.displayname .service "ShadowCanvas", [ "Runtime", "Documents", ShadowCanvasService]
module.exports = ShadowCanvasService