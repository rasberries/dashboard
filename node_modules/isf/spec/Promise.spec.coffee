
IS      = require "./IS"
chai    = require "chai"
Promise = IS.Promise
do chai.should

describe "Promise", ->

	it "should constuct properly", ->
		x = new Promise()

		x.callbacks.length.should.equal 0

		y = new Promise(x)
		y.should.equal x

	it "should run fine",  (done) ->
		x = new Promise()
		x.then((val) -> val.should.equal 5; done() )
		x.resolve(5)

	it "should chain properly", (done) ->
		op = (val) ->
			x = new Promise(@)
			setTimeout ->
				x.resolve val + 1
			, 5
			x

		op1 = op
		op2 = op
		op3 = op

		op1(4).then(op2).then(op3).then( (result)->
			result.should.equal 7			
			done()
		)

	it "should get errors right", (done) ->
		tick = (val) -> 
			x = new Promise(@)
			setTimeout -> 
				if val is 3 then x.reject val
				else x.resolve val + 1
			, 1
			x
		errtick = (val) -> 
			x = new Promise(@)
			setTimeout ->
				x.reject val
			, 1
			x

		op1 = tick
		op2 = tick
		op3 = tick
		
		ope1 = errtick
		ope2 = errtick
		ope3 = errtick

		op1(1).then(op2, ope2).then(op3, ope3).then((->),((val) ->
				val.should.equal 3
				done()
			))

	it "should pass an every-day result", (done) ->
		test = (value) ->
			x = new Promise(@)
			
			setTimeout ->
				if value % 2 is 0 then x.reject new Error("It works"), value
				else x.resolve value * 3
			, 15
			x

		reject = (error, value) -> 
			x = new Promise(@)
			setTimeout ->
				x.reject error, value
			, 1
			x
			
		test(1).then(test, reject).then((val) -> 
			val.should.equal 9
			test(2).then(test, reject).then(test, reject).then(( -> ), (error, value) -> error.message.should.equal "It works"; value.should.equal 2; done())
		)

	it "Should progress nicely", (done)->
		op = (val) ->
			x = new Promise(@)
			x.progress 1
			setTimeout ->
				x.progress 2
				x.resolve val + 1
			, 5
			x

		number = 0
		prog = (val) -> number += val

		op1 = op
		op2 = op
		op3 = op

		op1(4).then(op2, null, prog).then(op3, null, prog).then( (result)->
			result.should.equal 7	
			number.should.equal 5
			done()
		)
	it "Should work with faster resolving" ,(done)->
		op = (val) ->
			x = new Promise(@)
			val.should.equal value + tick
			tick++
			x.resolve val+1
			x

		op1 = op2 = op3 = op
		tick = 0; value = 1
		prom = op1(value)
		setTimeout(-> 
			prom.then(op2).then(op3).then((val)->
				val.should.equal 4
				done()
			)
		, 200)
