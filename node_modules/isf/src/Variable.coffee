# A variable (property) quick class to handle setters and getters. No fancy voodoo here, just comodity stuff :)
class Variable extends require "Object"

	# A shorthand to distribute variables. Spawn will be much easier used than `reuse`
	@spawn = ->
		x = new @
		x._value = null
		x

	# Getter function
	get: () ->
		return @_value

	# Setter function
	# @param [Object] value The value to be saved
	set: (value) ->
		@_value = value

	# Adder function
	# If you wish to use the variable as an array, then use this function to add reccords into the array
	# @param [Mixed] reccord The reccord to be added to the collection
	add: (reccord) ->
		if not @_value? or @_value.constructor isnt Array then @_value = []
		@_value.push reccord


# Finally, the class is sent through CommonJS if available
module?.exports = Variable
