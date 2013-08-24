module.exports = Controller: Controller, Bootstrap: (cntr, name, args) ->
	Controller = new cntr()
	args.push Controller.init
	angular.module "Revelation" .controller name, args
	module.exports = Controller
