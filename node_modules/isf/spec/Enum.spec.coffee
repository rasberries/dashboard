IS   = require "./IS"
chai = require "chai"
Enum = IS.Enum
do chai.should

describe "Enum Constructor", ->

	it "Should construct properly", ->
		x = new Enum( [ "TESTING", "NEW", "THING" ], 1 )
		x.TESTING.should.equal 1
		x.NEW.should.equal 2
		x.THING.should.equal 3
