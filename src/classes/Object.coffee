_baseObj =
	echo: (args...) ->
		_d = new Date
		owner = "<not supported>"
		if @__proto__? then owner = @__proto__.constructor.name
		args[0] = "[#{do _d.getHours}:#{do _d.getMinutes}:#{do _d.getSeconds}][#{@name or owner}]	#{args[0]}"
		console.log args
		@
		
	log: (args...) ->
		args.unshift ""
		@echo.apply @, args

class BObject extends IS.Object
	@extend _baseObj
	@include _baseObj

module.exports = window.BaseObject = BObject
