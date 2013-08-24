IS     = require "./IS"
chai   = require "chai"
obj    = IS.Variable

do chai.should

_count = (json) ->
	nr = 0
	nr++ for key, value of json
	nr

describe "Variable Object", ->

	it "Should spawn properly", ->
		n = obj.clone()
		n.should.equal n
		
		x = n.spawn()
		x.should.be.an.instanceof n

	it "Should have different values for different variables",  ->
		n = obj.clone()
		z = n.spawn()
		y = n.spawn()

		y.set true
		z.set false
		(do y.get).should.not.equal do z.get
		(do y.get).should.equal true
		(do z.get).should.equal false
