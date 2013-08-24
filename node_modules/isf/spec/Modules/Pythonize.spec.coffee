IS = require "../IS"
chai = require "chai"
obj = IS.Object

do chai.should

describe "Function Pythonize Module", ->

	it "make basic parameter parsing", ->
		class object extends obj
			get: IS.Modules.Pythonize.parameterize([ 
				"name"
				"surname" 
			], (options) -> "#{options.name} #{options.surname}" )
		inst = new object()

		( inst.get "Anca", "Gramada" ).should.equal "Anca Gramada"

	it "handle defaults", ->
		class object extends obj
			get: IS.Modules.Pythonize.parameterize([ 
				"name"
				{ name: "surname", default: "NOBODY" }
			], (options) -> "#{options.name} #{options.surname}" )
		inst = new object()

		( inst.get "Anca" ).should.equal "Anca NOBODY"

	it "handle a basic complex example", ->
		class object extends obj
			get: IS.Modules.Pythonize.parameterize([ 
				"name"
				{ name: "surname", default: "NOBODY" }
			], (options) -> "#{options.name} #{options.surname}" )
		inst = new object()

		( inst.get name: "Anca", surname: "Becali" ).should.equal "Anca Becali"

	it "handle a mixed complex example", ->
		class object extends obj
			get: IS.Modules.Pythonize.parameterize([ 
				"name"
				{ name: "surname", default: "NOBODY" }
				"age"
			], (options) -> "#{options.name} #{options.surname}, age: #{options.age}" )
		inst = new object()

		( inst.get "Anca", age: 13, surname: "Becali" ).should.equal "Anca Becali, age: 13"

	it "handle a heavy example", ->
		class object extends obj
			get: IS.Modules.Pythonize.parameterize([ 
				"name"
				{ name: "surname", default: "NOBODY" }
				"age"
			], (options) -> "#{options.name} #{options.surname}, age: #{options.age}" )
		inst = new object()

		( inst.get "Anca", age: 13).should.equal "Anca NOBODY, age: 13"
