chai   = require "chai"
expect = chai.expect

describe "Spec testing", ->
	it "Should get negated false to be true", ->
		(expect !false).to.equal true
	it "Should get operations done right", ->
		(expect	2*2).to.equal 4
		(expect 4/2*3).to.equal 6
	it "Should get awkward stuff right", ->
		(expect 5 + + "6").to.equal 11
		(expect 5 + "6").to.equal "56"
		(expect 6 + + + "7").to.equal 13
