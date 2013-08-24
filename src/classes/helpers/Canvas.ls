class CanvasService extends DepMan.renderer "Base" 
	(@runtime, @documents, @shadow) ~> 
		@log "CanvasService initialized"
		super ($ '#mindmap > canvas'  .0)
		window.addEventListener \resize, @resize
		@buffer.addEventListener \mousedown, @ev-down
		@buffer.addEventListener \mousemove, @ev-move
		@buffer.addEventListener \mouseup, @ev-up
		@buffer.addEventListener \touchstart, @ev-down
		@buffer.addEventListener \touchmove, @ev-move
		@buffer.addEventListener \touchend, @ev-up
		@runtime.subscribe \prop-active-document-change, ~> @reset!
		@offsets ?= x: 0, y: 0
		@shadow.offsets = @offsets
		@set-taps!
		@resize!

	resize: ~>
		@start-resize!
		@buffer.width = window.innerWidth
		@buffer.height = window.innerHeight - 49
		@end-resize!

	set-taps: ~>
		target = Hammer ($ '#mindmap > canvas' .0)
		target.on "doubletap", ~> @new-root!

	sequence: ~>
		doc = @documents._reccords[@runtime.props['active-document']]
		if doc 
			@active = true
			@reset!
			# Handling Offsets
			@decelerate!
			@context.translate @offsets.x, @offsets.y
			# First Pass, Lines
			for node in doc.indexes when node.$hidden isnt true
				if node.$linerenderer then let r = node.$linerenderer
					unless r.drawing or r.resizing or @drawing or @resizing
						@context.drawImage r.buffer, r.points.first.x + 150, r.points.first.y + 25
			# Second Pass, Nodes
			for node in doc.indexes when node.$hidden isnt true
				unless node.$renderer.drawing or node.$renderer.resizing or @drawing or @resizing
					@context.drawImage node.$renderer.buffer, node.location.x, node.location.y
				
			if @functional then requestAnimationFrame @sequence
		else @active = false

	start: ~> @functional = true; requestAnimationFrame @sequence
	end: ~> delete @functional

	get-target: ~> (@shadow.scan x: it.clientX, y: it.clientY - 45) - 1
	get-node: ~> @documents._reccords[@runtime.props['active-document']].indexes[it]
	get-point: ~>
		if it.touches then it.touches.0
		else it

	ev-down: ~>
		if @active
			point = @get-point it
			target = @get-target point
			if target >= 0 then 
				target = @get-node target 
				@target = target
				@offset = x: point.clientX - target.location.x, y: point.clientY - target.location.y - 45
			else @accelerate point
	ev-move: ~>
		if @active
			point = @get-point it
			if @target
				@dragging = true
				Client.publish "node.move", @target.$index, point.clientX - @offset.x, point.clientY - @offset.y - 45
			else if @accelerating then @accelerate point
	ev-up: ~>
		if @active
			if not @dragging
				target = @get-target @get-point it
				if target >= 0 then @edit @get-node target  
			delete @dragging if @dragging
			delete @target if @target
			delete @offset if @offset
			delete @accelerating if @accelerating
			delete @points if @points

	decelerate: ~>
		@acceleration ?= x: 0, y: 0
		unless @accelerating

			@acceleration.x -= @acceleration.x * DECEL_FACTOR
			@acceleration.y -= @acceleration.y * DECEL_FACTOR

			@offsets.x += @acceleration.x
			@offsets.y += @acceleration.y

	accelerate: ~>
		@points ?= []
		@accelerating = true
		@points.push p: it, t: new Date!
		if @points.length > 10 then @points.shift!
		if @points.length > 2 
			@calculate-acceleration!

			@offsets.x += @acceleration.x
			@offsets.y += @acceleration.y

	calculate-acceleration: ~>
		first = @points[*-1]
		last = @points[0]
		deltas = 
			t: first.t - last.t
			x: first.p.clientX - last.p.clientX
			y: first.p.clientY - last.p.clientY
		@acceleration = x: deltas.x / deltas.t * ACCEL_FACTOR, y: deltas.y / deltas.t * ACCEL_FACTOR



const DECEL_FACTOR = 0.15
const ACCEL_FACTOR = 15

angular.module AppInfo.displayname .service "Canvas", [ "Runtime", "Documents", "ShadowCanvas" CanvasService]
module.exports = CanvasService
