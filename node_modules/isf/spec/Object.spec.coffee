IS     = require "./IS"
chai   = require "chai"
obj    = IS.Object

do chai.should

describe "Barebone Object", ->

	it "should clone properly", ->

		newobj = obj.clone()

		newobj.extend
			"Chestie": "Naspa"
		newobj.include 
			potato: [
				{ "chestie": "naspa" }
				"barabula"
				"cartof"
			]
		inst = new newobj

		newobj.Chestie.should.equal "Naspa"
		inst.should.have.property("potato")
		newobj.should.not.have.property("potato")
		inst.potato.should.contain "barabula"
		inst.potato.should.contain "cartof"
		inst.potato.should.have.deep.property "[0].chestie", "naspa"
		obj.should.not.have.property("Chestie")
		(new obj).should.not.have.property("potato")

	it "Should clone other objects properly", ->

		class object
			@prop: "Sabin"

		newobject = obj.clone object
		newobject.prop = "Irina"

		object.prop.should.equal "Sabin"
		newobject.prop.should.equal "Irina"
		object.prop.should.not.equal newobject.prop

	it "Should Extend and Include properly", ->

		class Primitive extends IS.Object
			@classprop1: "Class Prop Primitive"
			@classprop2: -> "Primitive"
			instprop1: "Instance Prop Primitive"
			instprop2: -> "Instance Primitive"

		class Mixin
			@classprop1: "Mixin Object"
			instprop2: -> "Mixin Instance"

		Primitive.classprop1.should.equal "Class Prop Primitive"
		Primitive.prototype.instprop2().should.equal "Instance Primitive"

		Mixin.classprop1.should.equal "Mixin Object"
		Mixin::instprop2().should.equal "Mixin Instance"
	
	it "Should Extend and Include properly", ->

		class Primitive extends IS.Object
			@classprop1: "Class Prop Primitive"
			@classprop2: -> "Primitive"
			instprop1: "Instance Prop Primitive"
			instprop2: -> "Instance Primitive"

		class Mixin
			@classprop1: "Mixin Object"
			instprop2: -> "Mixin Instance"

		Primitive.extend Mixin
		Primitive.include Mixin::

		Primitive.classprop1.should.equal "Mixin Object"
		Primitive::instprop2().should.equal "Mixin Instance"

		Primitive.classprop2 = -> @::instprop1

		Primitive.classprop2().should.equal "Instance Prop Primitive"

		Primitive.classprop2 = -> @super

		Primitive.classprop2().classprop1.should.equal "Class Prop Primitive"


