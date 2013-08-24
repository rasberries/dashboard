###
# The constructor of the IS Framework.

This file is called when using `require "IS"` to brin the app to the window namespace
###
IS =
	Object: require "Object"		
	Variable: require "Variable"
	Modules: 
		ORM: require "Modules/ORM"
		Observer: require "Modules/Observer"
		Mediator: require "Modules/Mediator"	
		StateMachine: require "Modules/StateMachine"	

window?.IS = IS
module?.exports = IS
	