# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.










# When defining the Parer "class", there are basically two
# objects defined : The Parser object (@), and its prototype (without @)
#
# This is extremely powerful, and logical to use
# There are many ways to use this to your advantage.
# Right now, I'm using the class object (@) to create the interface when
# loading the module, and the instance object to create an instanceable
# object that will parse only one value set.
# Also, there will always be only one set saved into memory, and parsed.
class Parser

	# This is where the active parser object will be kept
	@_activeParser = null
	# Trying to keep track of the last argv set analyzed
	@_lastArgv = null

	# The parse interface either retrieves the active parser,
	# either starts using a new one :) 
	@parse: (arg, opts = {}) ->
		# If arguments are not supplied then an error is triggered
		throw ErrorReporter.generate 1 if not arg?

		# If anything has changed since last time, then reuse that result
		if @_activeParser? and @_lastArgv is arg then @_activeParser.results

		# Otherwise, force-parse the arguments received
		else @reparse arg, opts
	
	# Using the reparse function as a force-parse function
	@reparse: (arg, opts = {}) ->

		# Treat the no-arguments case
		throw ErrorReporter.generate 1 if not arg?

		# Generate a new parser to build the new results
		@_activeParser = new Parser(arg, opts)
		@_activeParser.results

	# And now, the interface being created, let us focus on the instance object
	# The constructor is going to accept the arguments and then focus on parsing
	# the input received.
	constructor: (args, opts = {}) ->

		# Treating the no arguments case
		throw ErrorReporter.generate 2 if not args?

		# Now, to figure out of which type the arguments are. We only work with arrays :P
		if args.substr? then args = args.split " "
	
		# Initialize some class variables :
		# @S = Single Arguments (before any dash arguments)
		# @DS = Dash Arguments ( -o -p, etc)
		# @DDS = DoubleDash Arguments ( --watch --blowme, etc)
		# The single arguments variable will be a simple array
		# while the other two will be associative arrays which
		# bind each option with their arguments
		# We will need the rawArgs parameter when we walk the
		# array for arguments for each of the dash and double-
		# dash arguments.
		@s = []
		@ds = {}
		@dds = {}
		@rawArgs = args
		@results = {}
		@symlinkOptions = opts
	
		# Return the result of parsing the arguments
		do @_parse
	
	# Right now, we are working with an instance of the prototype
	# function, so this parse function will be individual.
	# Also, we have the @rawArgs item (the @ simply symbolizes
	# the "this" object. We currently have no connection to the class
	# object at this time.
	_parse: (args = @rawArgs) ->

		# Treating the identical arguments case (remember, we want to use this outside
		# the factory class object as well)
		@rawArgs = args if args isnt @rawArgs

		# Starting to parse the argv at index 0
		index = 0
	
		# Wrapping up with the single arguments quickly.
		@s.push @rawArgs[index++] while @rawArgs[index]? and @rawArgs[index][0] isnt "-"
	
		# Now for the single dash and double dash options.
		# We have no need for other functions connected to this object,
		# but we do need an auxiliary function that would walk the argv
		# and add the arguments of an option.
		# We'll just create an anonymous function here :P
		walk = (from) ->
		
			# Initializing a void list to be filled with the arguments
			list = []
		
			# Populating the list with items from the list, until we en-
			# counter another dash option.
			list.push @rawArgs[from++] while @rawArgs[from]? and @rawArgs[from][0] isnt "-"
		
			# Returning the list to the caller
			list
		
	
		# Okay, so maybe we need another function :)
		# This can be avoided by adding another argument to the walk
		# function to supply @rawArgs, but honestly, I prefer to do
		# this the JavaScript way and defer ownership to the Parser instance
		# by using an auxiliary bootstrap function.
	
		# Saving the scope :
		_parser = @
		# And bootstrapping it, CoffeeScript style :D
		run = (what, args...) -> what.apply _parser, args
	
		# All done! Now, let's get it on!
		while @rawArgs[index]?
		
			# Calculating the arguments list
			results = run walk, index + 1
		
			# Inserting it into the proper list
			if @rawArgs[index][1] is "-" then @dds[@rawArgs[index].substr 2] = results
			else @ds[@rawArgs[index].substr 1] = results
		
			#Incrementing the index properly
			index += results.length + 1

		# Checking for symlinks (link single to doubledash and otherwise)
		# Creating a function to handle the equalization of two segments
		_equal = (n1, n2, a1, a2) ->
			if a2[n2]? and a2[n2].length > 0
				a1[n1].push argument for argument in a2[n2]
			a2[n2] = a1[n1]

		# And then leveraging the parameters :)
		for what, link of @symlinkOptions
			if what[1] is "-" and @dds[what.substr 2]? then _equal (what.substr 2), (link.substr 1), @dds, @ds 
			else if @ds[what.substr 1]? then _equal (what.substr 1), (link.substr 2), @ds, @dds 
		
		# And now to beautify the output a bit ... :)
		# The last calculated line of a function is automatically turned into
		# a return statement by the compiler, even on an if statement, or a
		# while, for, whatever :)
		@results =
			single: @s
			dash: @ds
			doubledash: @dds
		
# And there we go, we make the parser class be the whole module.exports,
# and therefore, anything else is irellephant ;))1
module.exports = Parser


# Oh, one more thing. Since this project is more of a counter-argument against
# TypeScript, and thinking I already have error repporting embedded into my 
# TypeScript version of this module, let me implement it in the same ideea 
# as a class - instance usability :)
class ErrorReporter extends TypeError

	# We only need a generate function, that would generate the error
	# object to be returned to "throw"
	@generate: (errorCode) ->
		if ERRORS[errorCode]? then new ErrorReporter(errorCode)
		else new ErrorReporter(0)
	
	# In the constructor we create the error and then we wait :)
	constructor: (errorCode) ->
		if errorCode
			@name = "ParserError"
		else
			@name = "UnknownError"
		@message = ERRORS[errorCode]
		@errorCode = errorCode


ERRORS = [
	"There is no error to be handled by the Parser O.o"
	"No Arguments have been supplied in the factory"
	"No Arguments have been supplied in the parser object"
]
