class RecipeController extends IS.Object
	(@scope, @runtime, @recipe-model) ~> @get-model!config-scope!hook-events!

	config-scope: ~>
		@safeApply = (fn) ~>
			phase = @scope.$parent.$$phase
			if phase is "$apply" or phase is "$digest"
				if fn and (typeof(fn) is 'function')
					do fn
			else @scope.$apply(fn)
		@scope <<< @
		@
	get-model: ~> @recipes = @recipe-model._reccords; @recipe-model.controller = @; @
	hook-events: ~>
	toggle-editing: (recipe) ~>
		recipe.editing = not recipe.editing
		recipe.get-data!
		setTimeout LanguageHelper._translateAll, 50
	remove: (recipe) ~> @log @recipes, recipe; delete @recipes[recipe._uuid]; @safeApply!
	add-recipe: (recipe) ~> @recipe-model.new!
	add-stub: (to) ~> to.push url: "http://github.com/rasberries/", instructions: []; setTimeout LanguageHelper._translateAll, 50
	add-instruction: (to) ~> to.push command: "New Instruction"; setTimeout LanguageHelper._translateAll, 50
	remove-instruction: (whom, fr) ~> fr.splice (fr.indexOf whom), 1
	remove-stub: (whom, fr) ~> fr.splice (fr.indexOf whom), 1 

angular.module AppInfo.displayname .controller "RecipeController", ["$scope", "Runtime", "Recipe", RecipeController]