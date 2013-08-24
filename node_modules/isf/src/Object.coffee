
_excludes = ["included", "extended"]

clone = (obj) ->
	o = if obj instanceof Array then [] else {}
	for k, v of obj
		if v? and typeof v is "object" then o[k] = clone v
		else o[k] = v
	return o

$ = (what) -> $[what] or null

# Barebone Object that is to be augmented with modules 
# @author Sabin Marcu
# @version v0.1
class Obiect

	@clone: (obj = @)-> debugger ;(Obiect.proxy Obiect.include, (Obiect.proxy Obiect.extend, ->)(obj))(obj::)

	@extend: (obj, into = @) ->
		obj = clone obj
		for k, value of obj
			if not ((k in _excludes) or (obj._excludes? and k in obj._excludes))
				if into[k]?
					into.super ?= {}
					into.super[k] = into[k]
				into[k] = value
		obj.extended?.call(into)
		this

	@include: (obj, into = @) ->
		obj = clone obj
		into::[key] = value for key, value of obj
		obj.included?.call(into)
		this

	@proxy: () ->
		what = arguments[0]
		to = arguments[1]
		if typeof what == "function" 
			return (args...) => 
				what.apply to, args
		else return @[what]

	@delegate: (property, context) ->
		if (@_delegates?[property]? is false and @_deleagates[property] isnt false) then trigger "Cannot delegate member #{property} to #{context}"
		context[property] = @proxy(->
			@[property] arguments
		, @)

	@echo: (args...) ->
		_d = new Date
		owner = "<not supported>"
		if @__proto__? then owner = @__proto__.constructor.name
		prefix = "[#{do _d.getHours}:#{do _d.getMinutes}:#{do _d.getSeconds}][#{@name or owner}]"
		if args[0] is "" then args[0] = prefix
		else args[0] = "#{prefix} #{args[0]}"
		console.log args
		@

	@log: (args...) ->
		if IS?.isDev or window.isDev or root?.isDev or isDev
			args.unshift ""
			@echo.apply @, args
		@

	extended = ->
	included = ->

	@include
		proxy: @proxy
		log: @log
		echo: @echo

module.exports = Obiect
