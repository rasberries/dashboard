Modules = Observer : require "Modules/Observer"
# The mediator class acts as an airport to data streams.
class Modules.Mediator
	@::[key] = value for key, value of Modules.Observer

	# Install the mediator to an object, that can communicate with it.
	installTo = (object)	->
		@delegate "publish", object
		@delegate "subscribe", object
	included = ->
		@::queue = {}
		@::_delegates =
			publish: true
			subscribe: true
	extended = ->
		@queue = {}
		@_delegates =
			publish: true
			subscribe: true

module.exports = Modules.Mediator::
