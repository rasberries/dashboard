class Client extends IS.Object
	~> @config = root-url: "http://10.0.0.180:3000/"
	request: (something, successcb, errorcb) ~> 
		$.ajax {
			url: "#{@config.root-url}api/#something"
			success: successcb
			error: errorcb
		}
	post: (something, data, callback) ~> $.post something, data, callback
	login: (data, cb) ~> 
		@request "users/login?mail=#{data.mail}&password=#{data.pass}", (~> Toast "Success", "It worked! You're fucking logged in!"; cb!), ~> Toast "Error", "The mail/pass combination was a total fuckup"


window.Client = new Client()
angular.module AppInfo.displayname .value "Data", window.Client
module.exports = window.Client
