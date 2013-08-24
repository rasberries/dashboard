class LineRenderer extends DepMan.renderer "Base"
	(@node) ~> super!; @setup-size!; @sequence!
	setup-size: ~>
		@start-resize!
		@deltas = x: @node.location.x - @node.$parent.location.x, y: @node.location.y - @node.$parent.location.y
		@buffer.width = ( Math.abs @deltas.x ) + 1
		@buffer.height = ( Math.abs @deltas.y ) + 1
		@end-resize!

	sequence: ~>
		@setup-size!
		@reset!
		@set-points!
		@draw-line!
		@set-text-points!
		unless @node.relation is ""
			@rotate!
			@draw-text!

	set-points: ~>
		# Initial
		@points = first: {x: 0, y: 0}, second: {x: 0, y: 0}
		@rpoints = first: {x: 0, y: 0}, second: {x: 0, y: 0}
		# X Setup
		if @deltas.x > 0 
			@points.first.x = @node.$parent.location.x
			@points.second.x = @node.location.x
			@rpoints.first.x = 0
			@rpoints.second.x = @buffer.width 
		else 
			@points.first.x = @node.location.x
			@points.second.x = @node.$parent.location.x
			@rpoints.first.x = @buffer.width
			@rpoints.second.x = 0
		# Y Setup
		if @deltas.y > 0
			@points.first.y = @node.$parent.location.y
			@points.second.y = @node.location.y
			@rpoints.first.y = 0
			@rpoints.second.y = @buffer.height
		else
			@points.first.y = @node.location.y
			@points.second.y = @node.$parent.location.y
			@rpoints.first.y = @buffer.height
			@rpoints.second.y = 0

	draw-line: ~>
		@context.stroke-style = "rgb(100, 100, 100)"
		@context.begin-path!
		@context.move-to @rpoints.first.x, @rpoints.first.y
		@context.bezier-curve-to @rpoints.first.x + @deltas.x / 3, @rpoints.first.y + @deltas.y, @rpoints.second.x - @deltas.x / 3, @rpoints.second.y - @deltas.y, @rpoints.second.x, @rpoints.second.y
		@context.stroke!

	set-text-points: ~>
		@context.font = "normal 12px Verdana"
		@rpoints = @context.measure-text @node.relation
		@log @rpoints

	rotate: ~> 
		@log @buffer.width / 2 - @rpoints.width / 2, @buffer.height / 2 - 20
		@context.translate @buffer.width / 2, @buffer.height / 2
		@context.rotate Math.atan @buffer.height / @buffer.width / 8

	draw-text: ~> 
		@context.fill-style = 'rgba(256, 256, 256, 0.9)'
		@context.stroke-style = 'rgba(0, 0, 0, 0.2)'
		@context.fill-rect-r @rpoints.width / -2, -20, @rpoints.width * 2, 30, 4
		@context.stroke-rect-r @rpoints.width / -2, -20, @rpoints.width * 2, 30, 4
		@context.fill-style = "black"
		@context.fill-text @node.relation, 0, 0


module.exports = LineRenderer
