IS = require "./IS"
chai = require "chai"
obj = do IS.Object.clone

do chai.should

describe "Error Reporter", ->

	it "Should extend right", ->
		class item extends obj
			@extend IS.ErrorReporter

		( typeof item.generate ).should.equal "function"

	it "Should get the properties right", ->
		class item2 extends obj

			@errors:
				"Chestie": ["There is no space", "No more jizz"]
				"Naspa": ["Need more potassium", "Need Viagra"]

			@extend IS.ErrorReporter

		item2._indices.should.contain "An unknown error has occurred"
		item2._indices.should.contain "There is no space"
		item2._indices.should.contain "No more jizz"
		item2._indices.should.contain "Need more potassium"
		item2._indices.should.contain "Need Viagra"

		item2._errors.should.have.property "Unknown Error"
		item2._errors.should.have.property "Chestie"
		item2._errors.should.have.property "Naspa"

	it "Should generate errors properly", ->
		class item2 extends obj

			@errors:
				"Penis": ["No more Viagra", "Need potassium", "No banana for you"]
				"Vagina": ["Need a dildo", "No more wine"]

			@extend IS.ErrorReporter

		error0 = item2.generate 0
		error1 = item2.generate 1
		error2 = item2.generate 2
		error3 = item2.generate 3
		error4 = item2.generate 4
		error5 = item2.generate 5

		error0.name.should.equal "Unknown Error"
		error1.name.should.equal "Penis"
		error2.name.should.equal "Penis"
		error3.name.should.equal "Penis"
		error4.name.should.equal "Vagina"
		error5.name.should.equal "Vagina"

		error0.message.should.equal "An unknown error has occurred"
		error1.message.should.equal "No more Viagra"
		error2.message.should.equal "Need potassium"
		error3.message.should.equal "No banana for you"
		error4.message.should.equal "Need a dildo"
		error5.message.should.equal "No more wine"

		( item2.generate 3, "Stuff is fucked up!" ).message.should.equal "No banana for you - Extra Data : Stuff is fucked up!"

	it "Should return correct texts", ->
		class item2 extends obj

			@errors:
				"Penis": ["No more Viagra", "Need potassium", "No banana for you"]
				"Vagina": ["Need a dildo", "No more wine"]


			@extend IS.ErrorReporter

		error0 = item2.generate 0
		error1 = item2.generate 1
		error2 = item2.generate 2
		error3 = item2.generate 3
		error4 = item2.generate 4
		error5 = item2.generate 5


		( do error0.toString ).should.equal "[Unknown Error] An unknown error has occurred |0|"
		( do error1.toString ).should.equal "[Penis] No more Viagra |1|"
		( do error2.toString ).should.equal "[Penis] Need potassium |2|"
		( do error3.toString ).should.equal "[Penis] No banana for you |3|"
		( do error4.toString ).should.equal "[Vagina] Need a dildo |4|"
		( do error5.toString ).should.equal "[Vagina] No more wine |5|"
