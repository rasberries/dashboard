# A simple Enum constructor (you give a list of strings, and it binds them in an enum-like fashion)
class Enum

	# Create the enum items
	# @param items Array An array of strings symbolizing the enums
	constructor: (items, offset = 0) -> @[item] = key + offset for item, key in items
module.exports = Enum
