IS   = require "../IS"
obj  = IS.Object
chai = require "chai"
obj.extend IS.Modules.ORM

do chai.should

_count = (json) ->
	nr = 0
	nr++ for key, value of json
	nr

describe "ORM Testing", ->

	it "Should create the right reccords", ->
		o = obj.clone()

		o.create()
		( _count o._reccords ).should.equal 1
		n = o.create("with-id")
		( _count o._reccords ).should.equal 2
		n.should.equal o.get("with-id")

	it "Should create base props properly", ->
		o = obj.clone()

		o.addProp "baseProp"
		o._props.should.contain "baseProp"

		x = o.reuse()
		x.should.have.property "baseProp"

	it "Should update props on the fly", ->
		o = obj.clone()

		o.addProp "baseProp"

		a = o.reuse()
		b = o.reuse()
		a.should.have.property "baseProp"
		b.should.have.property "baseProp"

		o.addProp "afterProp"

		a.should.have.property "afterProp"
		b.should.have.property "afterProp"


	it "Should reuse properly", ->
		o = obj.clone()

		o.reuse()
		( _count o._reccords ).should.equal 1

		x = o.reuse "with-id"
		x.should.equal o.get "with-id"
		x.should.equal o.reuse "with-id"
		x._id.should.equal "with-id"

		y = o.reuse "with-data", {"data": "new"}
		y._id.should.equal "with-data"
		y.data.should.equal "new"

	it "Should get by object query properly", ->
		o = obj.clone()

		o.addProp("queryprop1")
		o.addProp("queryprop2")

		a = o.reuse()
		a.queryprop1.set "app"
		a.queryprop2.set "app2"
		b = o.reuse()
		b.queryprop1.set "progr"
		b.queryprop2.set "stuff2"

		( o.get { queryprop1: "app"} ).should.equal a

	it "Should retrieve multiple objects on object query", ->
		o = obj.clone()

		o.addProp("prop")

		a = o.reuse()
		b = o.reuse()
		c = o.reuse()

		a.prop.set true
		b.prop.set false
		c.prop.set true

		( o.get prop:true ).length.should.equal 2
		( o.get prop:true ).should.contain a
		( o.get prop:true ).should.not.contain b
		( o.get prop:true ).should.contain c

	it "Should retrieve an object on object query with multiple ", ->
		o = obj.clone()

		o.addProp("prop")
		o.addProp("prop2")

		a = o.reuse()
		b = o.reuse()
		c = o.reuse()

		a.prop.set true
		b.prop.set false
		c.prop.set true
		a.prop2.set 2
		b.prop2.set 2
		c.prop2.set 3

		results = o.get prop: true, prop2: 2
		results.should.equal a

	it "Should retrieve objects with modifier matchers", ->
		o = obj.clone()

		o.addProp("prop")
		o.addProp("prop2")

		a = o.reuse()
		b = o.reuse()
		c = o.reuse()

		a.prop.set 3
		b.prop.set 5
		c.prop.set 8

		( o.get prop: {"$gt": 5} ).should.equal c
		( o.get prop: {"$lt": 5} ).should.equal a
		( o.get prop: {"$gte": 5} ).should.contain c
		( o.get prop: {"$gte": 5} ).should.contain b
		( o.get prop: {"$gt": 3, "$lt": 8} ).should.equal b

		a.prop2.add 1
		a.prop2.add 4
		a.prop2.add 5
		
		b.prop2.add 6
		b.prop2.add 7
		b.prop2.add 8

		c.prop2.add 1
		c.prop2.add 2
		c.prop2.add 3

		results = o.get prop2: {"$contains": 1}
		results.should.contain a
		results.should.contain c

	it "Should retrieve items between two delimiters", ->
		o = obj.clone()

		o.addProp("prop")

		a = o.reuse()
		b = o.reuse()
		c = o.reuse()
		d = o.reuse()


		a.prop.set 1
		b.prop.set 2
		c.prop.set 3
		d.prop.set 4

		( _count o.get prop: {"$gt": 1, "$lt": 4} ).should.equal 2
		( o.get prop: {"$gt": 2, "$lt": 4} ).should.equal c
