require("coffee-script");
var parser = require("cliparser"),
	args   = parser.parse(process.argv, {
		"-v": "--version",
		"-h": "--help",
		"-c": "--compile",
		"-p": "--port",
		"-a": "--address",
		"-s": "--static",
		"-l": "--location",
		"-b": "--bundle",
		"-v": "--verbose"
	})["doubledash"];

if (args.version) {
	var info = require("./package.json")
	console.log(info.version);
} else if (args.help) {
	var info = require("./package.json");
	require("./server/help")(info)
} else {
	var Compiler = null, Static = null, json = require("./package.json");
	if (args.compile) {
		var location = args.location || __dirname + "/public"
		if (location[location.length - 1] !== "/") location += "/"
		var jsLocation = location + "js/" + json.name + ".js",
			cssLocation = location + "css/styles.css"
		Compiler = require("./server/compiler");
		Compiler.setAttribute("bundle", args.bundle);
		Compiler.setAttribute("verbose", args.verbose);
		Compiler.compile(jsLocation);
		if (args.location) return;
	}
	if (args.static) {
		var data = {};
		data.address = args.address || process.env.IP || "0.0.0.0"
		data.port    = args.port || process.env.PORT || "8080"

		var Static = require("./server/static"),
			server = new Static(data);
		if (Compiler !== null) server.connect(Compiler);
		server.start()
	}
}
