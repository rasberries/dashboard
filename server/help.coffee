module.exports = (info) ->
	console.log """\u001b[31m _______ _______ _______ _______ __   __ ______   ___ ___     ___  
	|       |       |       |       |  | |  |    _ | |   |   |   |   | 
	|    ___|    ___|  _____|_     _|  | |  |   | || |   |   |   |   | 
	|   | __|   |___| |_____  |   | |  |_|  |   |_||_|   |   |   |   | 
	|   ||  |    ___|_____  | |   | |       |    __  |   |   |___|   | 
	|   |_| |   |___ _____| | |   | |       |   |  | |   |       |   | 
	|_______|_______|_______| |___| |_______|___|  |_|___|_______|___| 
	\u001b[0m

	\u001b[34mVersion	\u001b[0m: \u001b[31m#{info.version}
	\u001b[34mAuthor	\u001b[0m: \u001b[31m#{info.author.name} <#{info.author.email}>

	\u001b[34mUsage \u001b[0m: node server [options]
		./script.sh [options]

	\u001b[34mOptions \u001b[0m:
		"""
	
	options =
		"-v, --version": "Display the version"
		"-h, --help": "Display the help dialog"
		"-c, --compile": "Run the compiler"
		"-l, --location": "Set the location for the output"
		"-s, --static": "Run the static testing server"
		"-p, --port": "Specify the port for the server"
		"-a, --address": "Specify the address for the server"

	spaces = 0
	spaces = key.length for key, descr of options when spaces < key.length
	spaces += 8
	
	console.log "	\u001b[31m\u001b[1m#{key} #{Array(spaces - key.length).join(" ")}\u001b[32m\u001b[22m#{descr}" for key, descr of options
	console.log "\n"


