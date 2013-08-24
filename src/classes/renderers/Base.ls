Object.getPrototypeOf(document.createElement("canvas").getContext("2d")).fillRectR = (x, y, w, h, r) ->
	r = 5	if typeof r is "undefined"
	@beginPath()
	@moveTo x + r, y
	@lineTo x + w - r, y
	@quadraticCurveTo x + w, y, x + w, y + r
	@lineTo x + w, y + h - r
	@quadraticCurveTo x + w, y + h, x + w - r, y + h
	@lineTo x + r, y + h
	@quadraticCurveTo x, y + h, x, y + h - r
	@lineTo x, y + r
	@quadraticCurveTo x, y, x + r, y
	@closePath()
	@fill()

Object.getPrototypeOf(document.createElement("canvas").getContext("2d")).strokeRectR = (x, y, w, h, r) ->
	r = 5	if typeof r is "undefined"
	@beginPath()
	@moveTo x + r, y
	@lineTo x + w - r, y
	@quadraticCurveTo x + w, y, x + w, y + r
	@lineTo x + w, y + h - r
	@quadraticCurveTo x + w, y + h, x + w - r, y + h
	@lineTo x + r, y + h
	@quadraticCurveTo x, y + h, x, y + h - r
	@lineTo x, y + r
	@quadraticCurveTo x, y, x + r, y
	@closePath()
	@stroke()

class BaseFrameBuffer extends IS.Object
	(@buffer) ~>
		unless @buffer then @buffer = document.createElement("canvas")
		@sbuffer = document.createElement("canvas")
		@context = @buffer.getContext "2d"
		@scontext = @sbuffer.getContext "2d"
	reset: ~> @buffer.width = @buffer.width
	draw-shadow: ~>
		@sbuffer.width = @sbuffer.width
		@get-shadow-color!
		@scontext.fill-style = @scolor
		@scontext.fill-rect 0, 0, @sbuffer.width, @sbuffer.height
	get-shadow-color: ~>
		r = 0; g = 0; b = (@node?.$index + 1) % 255;
		rest = r / 255
		if rest
			g = rest % 255
			rest = rest / 255
			if rest
				r = rest % 255
		@scolor = "rgb(#r, #g, #b)"
	scan: ~> 
		rgb = @context.get-image-data it.x, it.y, 1, 1 .data
		rgb[0] * 255 * 255 + rgb[1] * 255 + rgb[2]
	start-draw: ~> @drawing = true
	end-draw: ~> delete @drawing
	start-resize: ~> @resizing = true
	end-resize: ~> delete @resizing

module.exports = BaseFrameBuffer