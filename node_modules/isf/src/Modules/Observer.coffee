Modules = {}
# The Observer class (or EventHandler) is a module that bestows the capability to triggevents, and subscribe to them to any given object.
# This practice is enspecially useful in JavaScript / CoffeeScript because if its event-driven nature.
# @mixin
# @version v0.1
class Modules.Observer 

	# Delegate an event to a given handler belonging to the given object. <br>
	# If no object is supplied, then the window object is used.
	# @param [String] event The event to which the handler will be delegated (or subscribed)
	# @param [Function] handler The handler attached to the event.
	# @param [Object] object The object to which the handler belongs to (delegate data from that event).
	delegateEvent: (event, handler, object = window) ->
		event = event.substr 2 if (event.substr 0, 2) is "on" 
		@queue[event] ?= []
		c = @queue[event].length
		@queue[event].unshift ->
			handler.apply object, arguments
		c

	# Subscribe a handler belonging to the current object to a given event of itself.
	# @param [String] event The event to which to delegate the handler.
	# @param [Function] handler The handler to attach to the event.
	subscribe: (event, handler) ->
		@delegateEvent event, handler, @

	# Publish (trigger) to the event, also pushing data at the same time.
	# @param [String] event The event to publish to (trigger)
	# @param [Arguments...] data Any data you wish to send through the channel to any handler attached to the event.
	publish: (args...) ->
		event = args[0]
		args = args.splice 1
		if not event or not @queue[event]? then return @
		handler.apply @, args for key, handler of @queue[event] when key isnt "__head"
		@

	unsubscribe: (event, id) ->
		return null if not @queue[event]
		return null if not @queue[event][id]
		@queue[event].splice id, 1

	# When inlcuded, initialize an event queue (included = added to prototype)
	included: () ->
		@::queue = {}

	# When extended, initialize an event queue (extended = added to class)
	extended: () ->
		@queue = {}

module.exports = Modules.Observer::