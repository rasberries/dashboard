IS   = require "../IS"
obj  = IS.Object.clone()
chai = require "chai"

do chai.should
obj.extend IS.Modules.StateMachine

describe "StateMachine Module", ->


	it "Should have the properties when extended", ->
		o = obj.clone()

		o.should.have.property 'delegateContext'
		o.should.have.property 'activateContext'
		o.should.have.property 'deactivateContext'
		o.should.have.property '_contexts'
		o.should.have.property 'switchContext'
					  
	it "Should delegate contexts right", ->

		a =
			name: "barabula"
		o = obj.clone()
		o.delegateContext a

		a.should.have.property "activate"
		a.should.have.property "deactivate"
		(typeof a.activate).should.equal 'function'
		(typeof a.deactivate).should.equal 'function'

	it "Should find contexts appropriately", ->

		a =
			name: "barabula"
		b =
			name: "cartof"
		o = obj.clone()
		o.delegateContext a
		o.delegateContext b

		(o._find a).should.not.equal null
		(o._find b).should.not.equal null


	it "Should trigger functions accordingly",  ->
		
		a =
			name: "barabula"
			activate: -> @name
			deactivate: -> "booger"
		o = obj.clone()
		o.delegateContext a

		(do a.activate).should.equal a.name
		(do a.deactivate).should.equal "booger"

		(o.activateContext a).should.equal a.name
		(o.deactivateContext a).should.equal "booger"

	it "Should switch contexts accordingly", ->

		a =
			name: "barabula"
		b =
			name: "cartof"
		c =
			name: "potato"
		d =
			name: "tato"

		o = obj.clone()
		o.delegateContext a
		o.delegateContext b
		o.delegateContext c
		o.delegateContext d
		o.activateContext a

		(do o.switchContext).should.equal b
		(o.switchContext d).should.equal d
		(do o.switchContext).should.equal a

