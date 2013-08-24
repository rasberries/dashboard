# Including some base necessities and creating the compilation package (anonymously)
require "isf"
stitch   = require "stitchw"
stylus   = require "stylus"
nib      = require "nib"
path     = require 'path'
fs       = require "fs"
base     = path.resolve "@{__dirname}/../src/data/stylesheets"
json     = require path.resolve "@{__dirname}/../package.json"
pack     = stitch.createPackage
	"dependencies": ["./node_modules/isf/lib/isf.min.js", "./node_modules/pc2cs/src/ClientClient.coffee"]
	"paths": ["./src"]


# The Compiler Bootstrap
class Compiler

	@echo: (args...) ->
		_d = new Date
		owner = "<not supported>"
		if @__proto__? then owner = @__proto__.constructor.name
		args[0] = "[#{do _d.getHours}:#{do _d.getMinutes}:#{do _d.getSeconds}][#{@name or owner}] #{args[0]}"
		console.log args
		@

	@log: (args...) ->
		args.unshift ""
		@echo.apply @, args

	@talk: (args...) -> if @options["verbose"] then @log.apply @, args

	@sources: []
	@options: {}

	# Compile the application to its designated location.
	@compile: (to = "./public/js/#{json.name}.js", callback = null) ->
		try
			pack.compile (err, source) =>
				if err then return throw CompilerErrorReporter.generate 2, CompilerErrorReporter.wrapCustomError err
				critem = """
					#{require path.resolve "#{__dirname}/data/copyright"}
				"""
				@sources.push """
					window.AppInfo = #{fs.readFileSync path.resolve "@{__dirname}/../package.json"};
				"""
				@sources.push """
					// Writing Copyright Information to HTML
					var done = false;
					\nwindow.addEventListener('load', (function(){
						if (!done) {
							console.log("Written Copyright Information to HTML")
							x = document.createComment("#{critem.replace /\n/g, "\\n"}");
							document.documentElement.insertBefore(x, document.head);
							x = null;
							done = true;
						}
					}));
				"""
				@sources.push """
					/** COPYRIGHT
					#{critem}

					#{( require path.resolve "#{__dirname}/data/appinfo" )(json, new Date())}
					**/

					#{source}
				"""
				if @options["verbose"] then @sources.push "window.isDev = true;"
				source += src for src in @sources when src.substr?
				source += do src for src in @sources when src.apply?
				@sources.length -= 3 + (@options.verbose)
				added = false
				@compileStyles(null, (styles) =>
					source += """
					\n\nwindow.addEventListener('load', (function(){
						window.getStylesheets = function() {
							element = document.createElement('style');
							element.innerHTML = \"#{styles.replace(/\"/g, "'").replace(/\n/g, "")}\";
							element.id = \"compiled_styles\";
							return element;
						}
						new (require(\"Application\"))(window.getStylesheets);
					}))
					"""
					@talk "Compiled styles, now joining"
					if callback? then callback source
					try
						(require "fs").writeFileSync to.toString(), source, "utf8"
						console.log "Wrote sources to file"
					catch e then return throw CompilerErrorReporter.generate 3, CompilerErrorReporter.wrapCustomError e
					@talk "SENT"
					, true)
		catch e then return throw CompilerErrorReporter.generate 1, e

	@addSource: (source) ->
		@sources.push source

	@compileStyles: (to = "./public/css/styles.css", callback = null, override = false) ->
		@talk "Starting to compile styles"
		@talk to, callback, override
		@talk "Passed styles raincheck"
		try
			sty = (require "fs").readFileSync "#{base}/index.styl", "utf8"
			paths = [
				 "#{base}"
			]
			@talk "Got the data for the styles"
			stylus(sty).set("filename", "#{base}/index.styl").set("paths", paths).use(do nib).import("nib").render (err, css) =>
				@talk "Compiled the styles"
				if err then return throw CompilerErrorReporter.generate 4, CompilerErrorReporter.wrapCustomError err
				if callback? then callback css
		catch e
			throw CompilerErrorReporter.generate 5, CompilerErrorReporter.wrapCustomError e

	@setAttribute: (attr, value) -> @options[attr] = value

# Defining the Compiler Error Reporter
class CompilerErrorReporter extends IS.Object

	# Setting the error parameters
	@errors:
		"CompilationError": [
			"An error occured when compiling the application"
			"The compiler failed"
			"The styles failed"
			"An error occured when compiling the stylesheets"
		]
		"WriteError" : [
			"Couldn't write the application to the file"
			"Couldn't write the styles to the file"
		]


	# Making sure it behaves properly
	@extend IS.ErrorReporter

# Exporting the Compiler
module.exports = Compiler
