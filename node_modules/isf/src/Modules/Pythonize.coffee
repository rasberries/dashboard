Modules = {}

_count = (object) ->
	nr = 0
	nr++ for key, value of object
	nr

CRITERIA =
	args: (crit, args) -> args.length == crit

class Include

	# Designed to overload a function, into parameter sets. This should get interesting ... 
	# @param $set The overload set
	parameterize: (sets, callback) ->
		helper = new Modules.Pythonize(sets, callback)
		(args...) -> helper.parent = @; helper.verifyAll.apply helper, args

# An overload engine, capable of replacing a function with a handler that decides on which function to use based on the arguments (and sets given)
class Modules.Pythonize

	# Constructing an overload manager, working with sets
	# @example Example of a set
	#  
	# @param [Array] sets The sets to be processed
	constructor: (sets, @callback) ->
		@parent = null
		@_options = []
		for item in sets
			newItem =
				name: item.name or do item.toString
				default: item.default or null
			@_options.push newItem

	verifyAll: (@args...) =>
		@options = {}

		# Handling the first length - 1 arguments (expecting the last one to be either normal, or complex)
		len = @args.length - 1; i = 0
		while @args.length > 1
			curArg = @_options[i]
			arg = @args.shift()
			@options[curArg.name] = arg or curArg.default
			i++

		# And now to verify the last argument
		lastarg = @args.pop()
		items = @verifyObject lastarg, len
		if len < @_options.length - 1
			for i in [( len + ( items.length is 0 ))..( @_options.length - 1 )]
				if not ( @_options[i].name in items ) then @options[@_options[i].name] = @_options[i].default
		@callback.apply @parent, [@options]
		

	verifyObject: (obj, id) ->
		omits = []
		if typeof obj is "object" # Assuming it isnt a new String() or new Number() or anything ...
			for name, value of obj
				valid = false
				for option in @_options
					if option.name is name
						valid = true
						break
				if not valid then @options[@_options[id].name] = obj; return []
				else omits.push name; @options[name] = value
		else @options[@_options[id].name] = obj
		omits
					
			
		



module.exports = Include::
