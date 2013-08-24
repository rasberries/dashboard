class SwypeleftGesture extends BaseObject

	constructor: (@init) ->
		window.addEventListener "touchmove", @move
		window.addEventListener "touchend", @end
		@event = null

	move: (e) =>
		if @breakup? then return
		appscope = angular.element("[ng-controller='NGAsideController']").scope()
		docscope = angular.element("[ng-controller='OPMLController']").scope()
		pos = Swype.getParams e
		if pos.x - @init.x > _tolerance
			delta = pos.x - @init.x
			percent = delta / 2.5
			if appscope.sidebarstatus is "open"
				# Dealing with tabs now
				@event = "tabs"
				if @lastpos 
					if pos.x < @lastpos.x then @event = null
					else @event = "tabs"

				@currentTab ?= jQuery("body > aside article.active")
				@prevTab ?= @currentTab.prev()

				@currentTab.css "#{prefix}transition", "none" for prefix in _prefixes
				@currentTab.css "#{prefix}transform", "translateX(#{delta}px)" for prefix in _prefixes
				@currentTab.css "opacity", "#{(100 - percent) / 100}"

				@prevTab.css "#{prefix}transition", "none" for prefix in _prefixes
				@prevTab.css "#{prefix}transform", "translateX(-#{275 - delta}px)" for prefix in _prefixes
				@prevTab.css "opacity", "#{(percent) / 100}"

				@lastpos = pos
			else 
				# Dealing with the sidebar now ... I think
				return if docscope.view is "mindmap"
				if docscope.sidebarstatus
					# Should handle the document sidebar					
					return if docscope.view is "mindmap"
					@event = "docsidebar"
					if @lastpos 
						if pos.x < @lastpos.x then @event = null
						else @event = "docsidebar"

					@content ?= jQuery("body > article article > div")
					@log delta
					if delta < 100 
						@content.css "#{prefix}transition", "none" for prefix in _prefixes
						@content.css "#{prefix}transform", "translateX(-#{100 - delta}px)" for prefix in _prefixes
				else
					# Should handle the app sidebar
					@event = "appsidebar"
					if @lastpos 
						if pos.x < @lastpos.x then @event = null
						else @event = "appsidebar"

					@sidebar ?= jQuery("body > aside")
					@content ?= jQuery("body > article")

					if delta < 250 
						@content.css "#{prefix}transition", "none" for prefix in _prefixes
						@content.css "#{prefix}transform", "translateX(#{delta}px)" for prefix in _prefixes

						@sidebar.css "#{prefix}transition", "none" for prefix in _prefixes
						@sidebar.css "#{prefix}transform", "translateX(#{(-250 + delta) / 2}px)" for prefix in _prefixes
						@sidebar.css "opacity", "#{(percent) / 100}"

					@lastpos = pos
			do appscope.safeApply

	end: (e) =>
		@breakup = true
		appscope = angular.element("[ng-controller='NGAsideController']").scope()
		docscope = angular.element("[ng-controller='OPMLController']").scope()
		if @sidebar
			@sidebar.css "#{prefix}transition", "" for prefix in _prefixes
			@sidebar.css "#{prefix}transform", "" for prefix in _prefixes
			@sidebar.css "opacity", ""
		if @content
			@content.css "#{prefix}transition", "" for prefix in _prefixes
			@content.css "#{prefix}transform", "" for prefix in _prefixes
		if @currentTab			
			@currentTab.css "#{prefix}transition", "" for prefix in _prefixes
			@currentTab.css "#{prefix}transform", "" for prefix in _prefixes
			@currentTab.css "opacity", ""
			@prevTab.css "#{prefix}transition", "" for prefix in _prefixes
			@prevTab.css "#{prefix}transform", "" for prefix in _prefixes
			@prevTab.css "opacity", ""
		switch @event 
			when "tabs" then appscope.asidetab null, -1
			when "appsidebar" then do appscope.togglesidebar
		window.removeEventListener "touchmove", @move
		window.removeEventListener "touchend", @end

_prefixes = ["-webkit-", "-moz-", "-ms-", "-o-", ""]
_tolerance = 50

module.exports = SwypeleftGesture
