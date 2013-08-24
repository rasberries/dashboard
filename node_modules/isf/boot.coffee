stitch       = require "stitchw"
program      = require "commander"
CoffeeScript = require "coffee-script"
packagejson  = require "#{__dirname}/package.json"
fs           = require "fs"

pak = stitch.createPackage
	paths: [
		__dirname + "/src"
		__dirname + "/node_modules/async/lib"
	]
	dependencies: [
		__dirname + "/bootstraps/uuid.js"
	]


class Bootstrap
	@compile: (location = __dirname + "/lib/application.js", watch = null, callback = null) ->
		watch = program.watch or watch
		action = () ->
			pak.compile (err, data) ->
				if err then console.log "Error encountered at compiling : " + err.message
				else
					fs = require "fs"
					location = program.compile or location
					content = CoffeeScript.compile Walker.generate()
					back = process.env.PWD + "/src/"
					content = """
						(function(module){
							#{data}
							var require = this.require;
							#{content}
						}).call({}, typeof(module) == \"undefined\" ? (typeof(window) == \"undefined\" ? root : window) : module);
					"""
					fs.writeFile location, content, (err) ->
						if err then console.log "Error encountered at writing compiled file (location : #{location}: #{err.message}"
						else 
							console.log "Compiled to #{location}"
							root._ISRES = true
					callback(content) if callback?
		if not watch?	then action()
		else
			action()
			setInterval action, watch * 1000

	@server: (server, port) ->
		express = require "express"
		app = express.createServer()
		c = @compile
		app.configure ->
			app.use app.router
			app.use express.static(__dirname + (if program.documentation then "/docs" else ""))
			app.get "/lib/application.js", (req, res) ->
				c(null, null, (ct) ->
					res.send ct, { 'Content-Type': 'text/javascript' }, 201
				)
		port = program.port or port
		address = program.address or address
		app.listen port, address
		console.log "Start listening at #{address}:#{port}"

class Walker
	@generateOutput: ->
		output = "require 'Object'\nrequire 'async'\n"
		output += "IS =\n"
		output += @indent @files, 1, ""
		output += "\nwindow?.IS = IS\nmodule?.exports = IS\nroot?.IS = IS"
		return output

	@indent: (object, number, prefix) ->
		bprefix = ""
		bprefix = "#{bprefix}\t" for i in [1..number]
		string = ""
		for key, value of object
			if typeof value is "object" then string += "#{bprefix}#{key}: \n" + @indent(value, number + 1, "#{prefix}#{key}/") + "\n"
			else string = "#{bprefix}#{key}: require '#{prefix}#{value}'\n#{string}"
		string

	@generate: ->
		console.log "Generating"
		@files = {}
		@walkDir __dirname + "/src", @files
		@generateOutput @files

	@walkDir: (dir, into) ->
		Walker.uses++
		if fs.lstatSync(dir).isDirectory()
			files = fs.readdirSync dir
			for file in files
				if fs.lstatSync("#{dir}/#{file}").isDirectory()
					into[file] = {}
					Walker.walkDir "#{dir}/#{file}", into[file]
				else
					name = file.substr 0, file.indexOf "."
					into[name] = name

program.version packagejson.version
program.usage '[options] <file...>'
program.option "-p, --port <number>", "The port on which to start server", parseInt, 9323
program.option "-a, --address <string>", "The address on which to start the server", ((val) -> val), "127.0.0.1"
program.option "-c, --compile <string>", "Compile the application", ((val) -> val)
program.option "-w, --watch <number>", "Recompile every n seconds", parseFloat
program.option "-d, --documentation", "Serve documentation files with a standalone web server"
program.option "-s --specs", "Run specs instead"
program.parse process.argv

if program.compile then	Bootstrap.compile()
else if program.specs then Bootstrap.specs()
else Bootstrap.server()

root._ISRES = false
