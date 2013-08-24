Modules = {}
# @author Sabin Marcu 
# A StateMachine handles the ON / OFF state of several object delegates
# @version v0.1
# @since v0.1
class Modules.StateMachine

	# @private
	extended: -> 
		@_contexts = []
		@_activeContext = null
	# @private
	included: -> 
		@::_contexts = []
		@::_activeContext = null

	# @since v0.1
	# @param [Object] context The context to be delegated as a context.
	# @return [StateMachine] The StateMachine object, ready to be chained into another binding or activation.
	# Delegate an object to the statemachine (becomes a context). 
	delegateContext: (context) =>
		return null if @_find context
		l = @_contexts.length
		@_contexts[l] = context
		(context.activate = ->) if not context.activate?
		(context.deactivate = ->) if not context.deactivate?
		@

	# @since v0.1
	# @return [Number] The identifier of the current active context.
	# Returns the identifier of the current active context. Can prove useful when iterating.
	getActiveContextID: -> @_activeContext

	# @since v0.1
	# @return [Object] The current active context.
	# Returns the current active context. Can prove useful when iterating.
	getActiveContext: -> @_activeContext
	getContext: (context) -> @_contexts[context] or null

	# @private
	_find: (con) ->
		return value for key, value in @_contexts when con is key
		return null

	# @since v0.1
	# @param [Object] context The context to be activated.
	# Activates one of the delegated contexts.
	# @return [Mixed] Returns whatever the activation function of the delegated object is supposed to return.
	activateContext: (context) ->
		con = @_find context
		return null if not con?
		return true if @_activeContext == con
		@_activeContext = con
		return context.activate()

	# @since v0.1
	# @param [Object] context The context to be deactivated.
	# Deactivates one of the delegated contexts.
	# @return [Mixed] Returns whatever the deactivation function of the delegated object is supposed to return.
	deactivateContext: (context) ->
		return null if not (@_find context)?
		@_activeContext = null
		return context.deactivate()

	# @since v0.1
	# @param [Object] context The context to switched to.
	# Switches to a given context.
	# <br> 
	# If no context is supplied, then the context next to the one already active is activated.
	# @return [Object] The context to which the state has been switched to.
	switchContext: (context) ->
		if not context? 
			con = @_activeContext + 1
			if con is @_contexts.length then con = 0
		else
			con = @_find context
			return null if not con?
		@deactivateContext @_contexts[@_activeContext]
		@activateContext @_contexts[con]
		@_contexts[con]



module.exports = Modules.StateMachine::