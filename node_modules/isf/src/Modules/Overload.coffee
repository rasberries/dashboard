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
	overload: (sets) ->
		helper = new Modules.Overload(sets, @)
		(args...) -> helper.parent = @; helper.verifyAll.apply helper, args

# An overload engine, capable of replacing a function with a handler that decides on which function to use based on the arguments (and sets given)
class Modules.Overload

	# Constructing an overload manager, working with sets
	# @example Example of a set
	#   [
	#     one:
	#       if: args: 1
	#       then: -> "One argument"
	#     two:
	#       if: args: 2
	#       then: -> "Two arguments"
	#     two_and_object:
	#       if: 
	#         args: 2
	#         arg1: (arg) -> typeof arg is "object"
	#       then: -> "Two arguments and Object"
	#   ]
	#  
	#  // Will yield : One Argument / Two Arguments / Two Arguments and Object depending on the selection. ["something"] goes on the first, ["two", "args"] goes on the second, and [{something: "good"}, "and cool"] goes to the third set;
	# @param [Array] sets The sets to be processed
	constructor: (sets, @parent) ->
		@names    = []
		@verifies = []
		@handles  = []
		for name, set of sets
			@names.push		 name
			@verifies.push   set.if or null
			@handles.push    set.then or null
		for i in [0..@verifies.length - 1]
			for j in [i + 1..@verifies.length]
				if _count(@verifies[i]) < _count(@verifies[j])
					aux = @verifies[i]; @verifies[i] = @verifies[j]; @verifies[j] = aux
					aux = @names[i]; @names[i] = @names[j]; @names[j] = aux
					aux = @handles[i]; @handles[i] = @handles[j]; @handles[j] = aux

	# This function simply acts as a router, routing the handlers accordingly.
	# @param [Array] args The arguments passed to the original function
	verifyAll: (@args...) =>
		for set, key in @verifies when set?
			for what, how of set
				if not @verify what, how then break
				return @handles[key].apply @parent, @args
		return ( @handles["default"] or @handles[key - 1] ).apply @parent, @args

	# This function does the checks for any given set parameter
	# @param [String] what The name of the argument (can be predefined : args, or it can be defined as : arg# where # is the number of the argument in order of appearance)
	# @param [Function] how The handler function (or argumet in the case of predefined verifiers)
	verify: (what, how) =>
		if CRITERIA[what] then return CRITERIA[what] how, @args
		else
			what = parseInt(what.replace "arg", "") - 1
			return how.apply @parent, @args if @args[what]?
			return false



module.exports = Include::
