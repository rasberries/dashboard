const TABS = <[account applications devices develop]>; Tabs = new IS.Enum TABS
const STATES = <[asideopen asideclosed]>; States = new IS.Enum STATES

class AppRouter extends IS.Object
	(@scope, @runtime) ~> window.AppRouter = @; @config-scope!init-runtime!hook-keyboard!

	init-runtime: ~>
		DBStorage.get "active-tab", (tab ?= Tabs['account']) ~>
			@runtime.props['active-tab'] = @scope.active-tab = tab
			@runtime.subscribe 'prop-active-tab-change', (tab) ~> 
				@scope.active-tab = tab
				DBStorage.set 'active-tab', tab
				@safeApply!
			@safeApply!
		DBStorage.get 'tab-state', (tab ?= States['asideclosed']) ~>
			@runtime.props['tab-state'] = @scope.tab-state = tab
			@runtime.subscribe 'prop-tab-state-change', (tab) ~>
				@scope.tab-state = tab
				@runtime['tab-state'] = tab
				DBStorage.set 'tab-state', tab
				@safeApply!
			@safeApply!
		@

	hook-keyboard: ~>
		key = if Tester.mac then "cmd" else "ctrl"
		jwerty.key "#{key}+1", (e) ~> @runtime.set 'active-tab', Tabs['account']; e.preventDefault!
		jwerty.key "#{key}+2", (e) ~> @runtime.set 'active-tab', Tabs['applications']; e.preventDefault!
		jwerty.key "#{key}+3", (e) ~> @runtime.set 'active-tab', Tabs['devices']; e.preventDefault!
		jwerty.key "#{key}+4", (e) ~> @runtime.set 'active-tab', Tabs['develop']; e.preventDefault!
		jwerty.key "#{key}+shift+v", (e) ~> 
			if @runtime['tab-state'] is States['asideopen'] then @runtime.set 'tab-state', States['asideclosed']
			else @runtime.set 'tab-state', States['asideopen']
			e.preventDefault!
		target = Hammer ($ '#approuter-container' .0)

	config-scope: ~>
		@safeApply = (fn) ~>
			phase = @scope.$parent.$$phase
			if phase is "$apply" or phase is "$digest"
				if fn and (typeof(fn) is 'function')
					do fn
			else @scope.$apply(fn)
		@scope <<< @
		@

angular.module AppInfo.displayname .controller "AppRouter", ["$scope", "Runtime", AppRouter]