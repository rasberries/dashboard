# Defining some stuff first.
_count = (json) ->
	nr = 0
	nr++ for key, value of json
	return nr

describe "Parser Object", ->

	it "Should contain both functions", ->
		Parser = require "./Parser"

		(expect typeof Parser.parse).toBe "function"
		(expect typeof Parser.reparse).toBe "function"


describe "Parser Instance Object", ->
	 
	it "Should run the function right", ->
		Parser = require "./Parser"

		Parser.parse process.argv
		(expect true).not.toBe false

	it "Should generate error type 1", ->
		Parser = require "./Parser"

		try
			Parser.parse null
			(expect false).toBe true
		catch e
			(expect e).not.toBe null
			(expect e.name).toBe "ParserError"
			(expect e.message).toBe "No Arguments have been supplied in the factory"
			(expect e.errorCode).toBe 1


	it "Should generate error type 2", ->
		Parser = require "./Parser"
		try
			inst = new Parser null
			(expect false).toBe true
		catch e
			(expect e).not.toBe null
			(expect e.name).toBe "ParserError"
			(expect e.message).toBe "No Arguments have been supplied in the parser object"
			(expect e.errorCode).toBe 2


	it "Should run this custom test just right", ->
		Parser = require "./Parser"

		results = Parser.parse [
			"node"
			"run"
			"-o"
			"./lib/parse"
			"--watch"
			"for"
			"files"
			"--and"
			"search"
			"for"
			"--some"
			"crap"
			"-a"
			"good"
		]

		(expect results.single.length).toBe 2
		(expect results.single).toContain "node"
		(expect results.single).toContain "run"
		
		(expect _count results.dash).toBe 2
		(expect results.dash["o"]).toContain "./lib/parse"
		(expect results.dash["a"]).toContain "good"

		(expect _count results.doubledash).toBe 3
		(expect results.doubledash["watch"]).toContain "for"
		(expect results.doubledash["watch"]).toContain "files"
		(expect results.doubledash["and"]).toContain "search"
		(expect results.doubledash["and"]).toContain "for"
		(expect results.doubledash["some"]).toContain "crap"

	it "Should make some symlinks right", ->
		Parser = require "./Parser"

		results = Parser.parse [
			"node"
			"run"
			"-o"
			"./lib/parse"
			"--watch"
			"for"
			"files"
			"--and"
			"search"
			"for"
			"--some"
			"crap"
			"-a"
			"good"
		], { "-a" : "--watch", "--ceva", "-c" }

		(expect results.dash['a']).toContain "for"
		(expect results.dash['a']).toContain "files"
		(expect results.doubledash['watch']).toContain "good"
		(expect typeof results.dash['c']).toBe "undefined"
		(expect typeof results.doubledash['ceva']).toBe "undefined"



	it "Redundant checking + splicing", ->
		Parser = require "./Parser"

		results = Parser.parse "coffee ./lib/script --modify dependencies stuff -m version", { "--modify": "-m" }

		(expect results.dash["m"]).toContain "dependencies"
		(expect results.dash["m"]).toContain "stuff"
		(expect results.doubledash["modify"]).toContain "version"




