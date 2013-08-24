require "isf" # We're gonna need the ISF framework to help with ErrorReporting (for now)

class DataTransferServer

	constructor: (@server) ->
		if not @server? then @server = do _newServer
		@clients = {}