class Runtime extends IS.Object
	~> window.Runtime = @; @props = {}; @log "Runtime Activated!"
	get  : (prop) ~> @log "Got #prop"; @props[prop]
	set  : (prop, value) ~> @props[prop] = value; @publish "prop-#{prop}-change", value; @log "Prop #prop set to #value! [prop-#{prop}-change emitted]"
	init : (prop, type) ~>
		unless @props[prop]?
			@props[prop] = switch type
			| \array => []
			| \object => {}
			| \number, \boolean => 0
			| otherwise => ""
		@publish "prop-#{prop}-init"
		@log "Prop #prop initialized! [prop-#{prop}-init emitted]"

	@include IS.Modules.Observer

runtime = new Runtime()
angular.module AppInfo.displayname .value "Runtime", runtime
module.exports = runtime
