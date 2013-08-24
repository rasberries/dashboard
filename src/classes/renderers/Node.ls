class NodeRenderer extends DepMan.renderer "Base"
	(@node) ~> super!; @setup-size!; @sequence!
	setup-size: ~>
		@buffer.width = @sbuffer.width = 300
		@buffer.height = @sbuffer.height = 50

	sequence: ~>
		@reset!
		@set-styles!
		@gen-gradient!
		@draw-shape!
		@draw-text!
		@draw-shadow!

	set-styles: ~>
		@colors = switch @node.status
		| "indeterminate" => first: "rgb(0, 0, 0)", second: "rgb(50, 50, 50)", border: "rgb(100, 100, 100)", text: "rgb(256, 256, 256)"
		| "determinate" => first: "rgb(256, 256, 256)", second: "rgb(230 , 230 , 230 )", border: "rgb(150, 150, 150)", text: "rgb(40, 40, 40)"
		| "checked" => first: "rgb(0, 135, 255)", second: "rgb(0, 100, 220)", border: "rgb(40, 40, 40)", text: "rgb(256, 256, 256)"
		| otherwise => first: "rgb(255, 67, 16)", second: "rgb(220, 30, 0)", border: "rgb(40, 40, 40)", text: "rgb(256, 256, 256)"

	gen-gradient: ~>
		@grad = @context.createLinearGradient 0, 0, 0, @buffer.height
		@grad.add-color-stop 0, @colors.first
		@grad.add-color-stop 0.5, @colors.first
		@grad.add-color-stop 1, @colors.second

	draw-shape: ~>
		@context.fill-style = @grad
		@context.stroke-style = "rgb(0, 0, 0)"
		@context.line-height = 1
		@context.fill-rect-r 0, 0, @buffer.width, @buffer.height, 4
		@context.stroke-rect-r 0, 0, @buffer.width, @buffer.height, 4

	draw-text: ~>
		@context.fill-style = @colors.text
		@context.stroke-style = @colors.border
		@context.font = "normal 15px Verdana"
		text = @node.text; if text.length > 28 then text = "#{text.substr 0, 25}..."
		@context.stroke-text text, 20, 30
		@context.fill-text text, 20, 30


module.exports = NodeRenderer