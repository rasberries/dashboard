class SwyperightGesture extends BaseObject

	constructor: (@init) ->
		window.addEventListener "touchmove", @move
		window.addEventListener "touchend", @end

	move: (e) =>
		if @breakup? then return
		appscope = angular.element("[ng-controller='NGAsideController']").scope()
		docscope = angular.element("[ng-controller='OPMLController']").scope()
		pos = Swype.getParams e
		if @init.x - pos.x > _tolerance
			delta = @init.x - pos.x
			percent = delta / 2.5
			if appscope.sidebarstatus is "open"
				# Dealing with tabs now
				if @init.x <= 250 
					@event = "tabs"
					@log delta, percent
					if @lastpos 
						if pos.x > @lastpos.x then @event = null
						else @event = "tabs"

					@currentTab ?= jQuery("body > aside article.active")
					@prevTab ?= @currentTab.next()

					@currentTab.css "#{prefix}transition", "none" for prefix in _prefixes
					@currentTab.css "#{prefix}transform", "translateX(-#{delta}px)" for prefix in _prefixes
					@currentTab.css "opacity", "#{(100 - percent) / 100}"

					@prevTab.css "#{prefix}transition", "none" for prefix in _prefixes
					@prevTab.css "#{prefix}transform", "translateX(#{275 - delta}px)" for prefix in _prefixes
					@prevTab.css "opacity", "#{(percent) / 100}"
				else 
					# Should handle the app sidebar
					@event = "appsidebar"
					if @lastpos 
						if pos.x > @lastpos.x then @event = null
						else @event = "appsidebar"

					@sidebar ?= jQuery("body > aside")
					@content ?= jQuery("body > article")

					if delta < 250
						@content.css "#{prefix}transition", "none" for prefix in _prefixes
						@content.css "#{prefix}transform", "translateX(#{250 - delta}px)" for prefix in _prefixes

						@sidebar.css "#{prefix}transition", "none" for prefix in _prefixes
						@sidebar.css "#{prefix}transform", "translateX(-#{(delta) / 2}px)" for prefix in _prefixes
						@sidebar.css "opacity", "#{(100 - percent) / 100}"
			else
				return if docscope.view is "mindmap"
				@event = "docsidebar"
				if @lastpos 
					if pos.x > @lastpos.x then @event = null
					else @event = "docsidebar"

				@content ?= jQuery("body > article article > div")
				@log delta
				if delta < 100 
					@content.css "#{prefix}transition", "none" for prefix in _prefixes
					@content.css "#{prefix}transform", "translateX(-#{delta - 50}px)" for prefix in _prefixes
				
			@lastpos = pos

	end: (e) =>
		@breakup = true
		appscope = angular.element("[ng-controller='NGAsideController']").scope()
		docscope = angular.element("[ng-controller='OPMLController']").scope()
		if @content
			@content.css "#{prefix}transition", "" for prefix in _prefixes
			@content.css "#{prefix}transform", "" for prefix in _prefixes
		if @sidebar
			@sidebar.css "#{prefix}transition", "" for prefix in _prefixes
			@sidebar.css "#{prefix}transform", "" for prefix in _prefixes
			@sidebar.css "opacity", ""
		if @currentTab			
			@currentTab.css "#{prefix}transition", "" for prefix in _prefixes
			@currentTab.css "#{prefix}transform", "" for prefix in _prefixes
			@currentTab.css "opacity", ""
			@prevTab.css "#{prefix}transition", "" for prefix in _prefixes
			@prevTab.css "#{prefix}transform", "" for prefix in _prefixes
			@prevTab.css "opacity", ""
		switch @event 
			when "tabs" then appscope.asidetab null, 1
			when "appsidebar" then do appscope.togglesidebar
			when "docsidebar" then do docscope.toggleSidebar
		window.removeEventListener "touchmove", @move
		window.removeEventListener "touchend", @end

_prefixes = ["-webkit-", "-moz-", "-ms-", "-o-", ""]
_tolerance = 50

module.exports = SwyperightGesture
