Modules = {}

V = require "Variable"
# The ORM Module extends the object intended with ActiveReccords-like capabilities
# @mixin
class Modules.ORM

	_identifier: "BasicORM"
	_reccords: {}
	_symlinks: {}
	_head: 0
	_props: []

	# A shorthand for retrieving an object via its ID, symlink (organic ID) or property criteria.
	# @param [String] which ID - the default ID created by the ORM to identify unique reccords
	# @option which [String] ID - the organic ID given by the application / user / developer
	# @option which [Obiect] An object containing matchers to retrieve the object (passed to the {#getAdv} fnction)
	# @note Only properties added via the ORM can be matched
	get: (which) ->
		if typeof which is "object" then return @getAdv which
		return @_symlinks[which] or @_reccords[which] or null

	# Retrieves an object via property criteria
	# @param [Obiect] what The object containing all of the matchers
	# @note Any first level item may refer to an object containing a modifier ($gt, $lt, $gte, $lte, $contains)
	# @return [Obiect] The reccord requested or an array of reccords matching the given criteria.
	# @example How to find an object
	# 		ORM.getAdv Username: "Xulescu", Password: sha256("password", salt)
	# @example How to find an object using modifiers
	# 		ORM.getAdv Username: "Xulescu", AuthLevel: { $gte: 5, $lte: 8 }
	# 
	getAdv: (what) ->
		results = []

		check = (rec) ->
			for k, v of what
				final = false
				if not rec[k]?
					break
				if (typeof v) is "object"
					for mod, val of v
						modfinal = true
						switch mod
							when "$gt"
								if (do rec[k].get) <= val
									modfinal = false
									break
							when "$gte"
								if (do rec[k].get) < val
									modfinal = false
									break
							when "$lt"
								if (do rec[k].get) >= val
									modfinal = false
									break
							when "$lte"
								if (do rec[k].get) > val
									modfinal = false
									break
							when "$contains"
								recs = do rec[k].get
								if recs.constructor isnt Array
									modfinal = false
									break
								modfinal = false
								for value in recs
									if value is val
										modfinal = true
										break
						if modfinal is false then break
					if modfinal is true then final = true
				else if (do rec[k].get) is v then final = true
				else break
			if final then results.push rec

		check rec for key, rec of @_reccords		
		check rec for key, rec of @_symlinks

		if results.length is 0 then return null
		if results.length is 1 then return results[0]
		return results

	# Delete a reccord (either from the classic or symlinks)
	# @todo Remove symlink if reccord is found first, and remove reccord if symlink is found first
	# @todo Implement removing via object queries
	# @param which [String] The id of the reccord to remove
	delete: (which) ->
		@_reccords[which] ?= null
		@_symlinks[which] ?= null

	# Create a new reccord
	# @param id [String] The id of the new reccord (will be stored as a symlink, as the reccord will still have its own uuid)
	# @param args [Obiect] Optional arguments to be passed and processed by the reccords' init function (or embedded by default into the reccord)
	# @return [Obiect] The reccord recently created
	create:  (id, args) ->
		@_reccords ?= {}

		args ?= {}
		uuid = id or args._id or @_head
		args._id ?= uuid
		uuid = Math.uuidFast(uuid)
		args._uuid = uuid
		args._fn = @

		@preCreate?(args)
		@_reccords[uuid] = new @(args)
		@_reccords[uuid]._constructor(args)
		@postCreate?(@_reccords[uuid], args)

		@_symlinks[id] = @_reccords[uuid] if id? and id isnt @_head
		@_head++ if uuid is @_head
		for prop in @_props
			@_reccords[uuid][prop] = V.spawn()
		@_reccords[uuid]

	# A shorthand for retrieving reccords.
	# The requested reccord is firstly searched and, if found, retrieved.
	# If the reccord is not found, it is created, taking the second parameter as arguments for the creation function.
	# @param [String] which The reccord to retrieve
	# @param [Obiect] args The arguments to pass to the construction {#create} function.
	# @note The match argument is the same as in the {#get} function
	reuse: (which, args) ->
		args ?= {}
		rez = @get(which)
		if rez? then return rez
		return @create(which, args)
	
	# Add a property to all reccords (both present and future)
	# @param [String] prop The property's name
	# @note The properties added are all of class Variable
	# @see Variable
	addProp: (prop) ->
		@_props.push prop
		for key, rec of @_reccords
			rec[prop] ?= V.spawn()

	# Remove a property from all reccords (both present and future)
	# @param [String] prop The property's name
	removeProp: (prop) ->
		for key, rec of @_reccords
			rec[prop] ?= null
		for p, k in @_props
			if p is prop then return @_props.splice k, 1

	# Auxiliary class to integrate with {Obiect}'s {Obiect#extend} and  {Obiect#include} functions which trigger on the given events.
	extended: ->
		@_excludes = [
			"_fn"
			"_uuid"
			"_id"
		]
		@include {
			_constructor: (args) ->
				valueSet = {}
				@_uuid = args._uuid or null
				@_id = args._id or null
				@fn = args._fn
				valueSet[key] = value for key, value of args when (key not in @fn._excludes and (@constructFilter key, value) isnt false)
				return @init.call(@, valueSet) if @init?
				@[k] = v for k, v of valueSet

			constructFilter: (key, value) -> true
			remove: () ->
				@parent.remove @id
		}

	
module.exports = Modules.ORM::
 
	

