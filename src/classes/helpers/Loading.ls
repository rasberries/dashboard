class LoadingHelper extends IS.Object
	~>
		f = document.createElement "div"
		f.innerHTML = DepMan.render [\loading \index]
		document.body.appendChild f
		@loadingScreen = document.getElementById "loadingscreen"
		@asides = ( $ '#loadingscreen > aside' )[0 til 2]
		@message = document.getElementById "loadingmessage"
		window.addEventListener \resize, @resize
		do @resize
		@echo "Loading screen ready"

	start: ~> @loadingScreen.className = \active; @
	end: ~> @loadingScreen.className = ""; @
	resize: ~> @asides |> map -> 
		angle = Math.atan window.innerWidth / window.innerHeight
		arg = switch it.dataset.location
		| \left => "-50%"
		| \right => "50%"
		transString = "translateX(#{arg})  skew(#{angle}rad)"
		console.log transString
		$ it .css \transform, transString
		@
	progress: (arg) ~> 
		@message.innerHTML = switch typeof arg
		| \number => "Loading: #{arg}%"
		| otherwise => arg
		@

module.exports = LoadingHelper
