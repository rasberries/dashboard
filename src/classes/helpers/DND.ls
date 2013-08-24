class DragNDropService extends IS.Object
	(@models) ~> 
		window.DND = @
		window.addEventListener "dragenter", @enter
		window.addEventListener "dragleave", @leave
		window.addEventListener "dragstart", @nop
		window.addEventListener "dragend", @nop
		window.addEventListener "dragover", @nop
		window.addEventListener "drop", @drop

	enter: ~>
		@nop it
	leave: ~>
		@nop it
	drop: ~>
		@nop it
		for file in it.dataTransfer.files then let f = file
			type = f.name.substr ( f.name.lastIndexOf "." ) + 1 
			if type in [\opml \xml]
				reader = new FileReader!
				reader.onload = ~> @models.get-document it.target.result
				reader.read-as-text f
	nop: ~>
		it.preventDefault!
		it.stopPropagation!

angular.module AppInfo.displayname .service "DND", [ "Documents", DragNDropService]
