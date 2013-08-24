module.exports = (grunt) ->

	grunt.loadNpmTasks "grunt-simple-mocha"
	grunt.loadNpmTasks "grunt-contrib-uglify"

	grunt.initConfig
		pkg: grunt.file.readJSON "package.json"
		simplemocha:
			options:
				timeout: 3000
				ui: "bdd"
				compilers:
					coffee: "coffee-script"
			all:
				src: "spec/**/*.coffee"
		compile:
			location: "lib/isf.js"

	grunt.registerMultiTask "compile", "Compile Application", ->
		x = []
		x.push prop for prop in process.argv
		process.argv = ["node", "app", "--compile", @data]
		require "./server.js"
		process.argv = x

	grunt.registerTask "default", ["compile", "simplemocha"]
