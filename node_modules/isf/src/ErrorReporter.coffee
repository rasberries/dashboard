# An ErrorReporter base factory. It is the starting point for creating custom error reporters (throw error generators)
class ErrorReporter

	# A few base variables
	@_errors: {"Unknown Error": [ "An unknown error has occurred" ]}
	@_indices: [
		@_errors["Unknown Error"][0]
	]
	@_groups: [ "Unknown Error" ]


	# A function that would format the message of a previous error that needs to be included into the current one :)
	# @param [Error] error The error to be formatted
	# @return [String] The error string of the converted error object
	@wrapCustomError : (error) -> "[#{error.name}] #{error.message}"

	# A function to generate and link the error
	# @param [Number] errorCode The errorCode of the error to be generated
	# @param [String] extra Extra information to be included within the error
	# @return [ErrorReporter] A new ErrorReporter instance initialized with the data sent.
	# @example How to generate an error and throw it
	#   throw ErrorReporter.generate(errCode) // WARNING : Do not add "new" after throw.
	@generate : (errorCode, extra = null) -> return (new @).generate errorCode, extra

	# This function will be called when extending the item. This way, we can compile the list of errors on site.
	# @private
	@extended : ->
		for group, errors of @errors
			@_errors[group] = errors
			@_groups.push group
			for error, key in errors
				@_indices.push @_errors[group][key]
		@::_ = @
		delete @errors
		@include ErrorReporter::

	# Generates the error based on factory items
	generate: (@errCode, extra = null) ->
		if not @_._indices[@errCode] then @name = @_._groups[0]; @message = @_._errors[@_._groups[0]][0]
		else
			@message = @_._indices[@errCode]
			if extra then @message += " - Extra Data : #{extra}"
			for group, errors of @_._errors when @message in errors
				@name = group
				break
		@
		
	# Transforms the error message into a pretty text
	# @return [String] The error string required.
	# @example Test a string
	#   ErrorReporter.generate(0).toString() // => [Unknown Error] An unknown error has occurred |0|
	toString: => "[#{@name}] #{@message} |#{@errCode}|"


# And finally, exporting the commonjs module.
module.exports = ErrorReporter
