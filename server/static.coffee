require "isf" # We're gonna need the ISF framework to help with ErrorReporting (for now)

# Defining the Server Bootstrap class (the actual work is done by Express)
class Server

	# On construction we need an address and a port to start the server on
	# @param data Object An Object containing the address and port (both strings)
	# @return Server The server instance
	constructor: (data) ->

		for item, values of data
			if values.length <= 1 then data[item] = values[0]

		# Testing to check for the right value
		return throw ServerErrorReporter.generate 1 if not data.address?
		return throw ServerErrorReporter.generate 2 if not data.port?
		return throw ServerErrorReporter.generate 3 if not data.address.substr?
		return throw ServerErrorReporter.generate 4 if not data.port.substr?

		# Going forward with the construction
		@address = data.address
		@port = data.port

	# Connect a compiler or other objects (if some other dev enables it)
	# @param CompilerObject Compiler The compiler object to be attached to the static server.
	# @return Server The current server instance
	connect: (CompilerObject) ->

		# Checking for the right object
		return throw ServerErrorReporter.generate 5 if not CompilerObject?
		return throw ServerErrorReporter.generate 6 if not CompilerObject.compile?

		# Moving forward
		@compiler = CompilerObject
		@

	# Start the server on the address and port specified when constructing it
	# @return Server The current server instance
	start: ->

		# Grabbing Express and checking if it is there
		Express = require "express"
		return throw ServerErrorReporter.generate 7 if not Express?

		try # Attempt to configure the server and return an error
			App = do Express
			Server = require("http").createServer App
			App.configure =>
				App.use Express.bodyParser()
				App.use App.router
				App.use Express.static((require "path").resolve("#{__dirname}/../public"))
				try
					DataServer = new ( require "pc2cs" )(App, @compiler?, Server)
				catch e
					throw ServerErrorReporter.generate 10, ServerErrorReporter.wrapCustomError e
				App.post "/echo/:id", (req, res) =>
					res.setHeader "Content-disposition", "attachment; filename=#{req.params.id}"
					res.setHeader "Content-type", "text/x-opml"
					console.log "Sending #{req.params.id}"
					res.send req.body.content
				if @compiler?
					@compiler.addSource DataServer.compileClientSource
					App.get "/js/tadpole.js", (req, res) => @compiler.compile null, (source) ->
						res.send source, {"Content-Type": "application/javascript"}, 201
					App.get "/css/styles.css", (req, res) => @compiler.compileStyles null, (source) ->
						res.contentType "text/css"
						res.send source, {"Content-Type": "text/css"}, 201
					@compiler.addSources
				App.get "/font/*", (req, res) => res.sendfile (require "path").resolve "#{__dirname}/../public#{req.url}"
				App.get "/images/*", (req, res) => res.sendfile (require "path").resolve "#{__dirname}/../public#{req.url}"
				App.get "/manifest.webapp", (req, res)  => res.sendfile (require "path").resolve "#{__dirname}/../public#{req.url}"
				App.get "/arrow_up_1.png", (req, res)  => res.sendfile (require "path").resolve "#{__dirname}/../public#{req.url}"
				App.get "*", (req, res) =>
					(require "fs").exists ((require "path").resolve "#{__dirname}/../public#{req.url}"), (exists) ->
						if exists then res.sendfile ((require "path").resolve "#{__dirname}/../public#{req.url}")
						else res.sendfile (require "path").resolve("#{__dirname}/../public/index.html")
		catch e then return throw ServerErrorReporter.generate 8, ServerErrorReporter.wrapCustomError e

		# Finally launch the server
		try
			Server.listen @port, @address
			console.log "Started the static server on address : #{@address}, and port : #{@port}"
			console.log "Instant compiling is enabled." if @compiler?
			
		catch e
			throw ServerErrorReporter.generate 9, ServerErrorReporter.wrapCustomError e
		@

# Defining the ErrorReporting for the Server class
class ServerErrorReporter extends IS.Object

	# Defining the error messages, assigning them to groups and naming them.
	@errors = 
		"ConstructorError": [
			"There is no address supplied"
			"There is no port supplied"
			"The address is not a string"
			"The port is not a string"
		]
		"CompileConnectionError": [
			"There was no object supplied"
			"The object supplied was not compatible"
		]
		"InternalError": [
			"Express module was not installed"
			"Error at configuring the server"
			"Error at starting the server"
			"Error at starting the data transfer server"
		]

	# Making sure it behaves as it should
	@extend IS.ErrorReporter


# Exporting the server
module.exports = Server


