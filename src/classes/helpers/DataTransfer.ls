class Client extends IS.Object
	~> @config = root-url: "http://10.0.0.180:3000/"
	request: (something, successcb, errorcb) ~> 
		$.ajax {
			url: "#{@config.root-url}api/#something"
			success: successcb
			error: errorcb
		}
	post: (something, data, successcb, errorcb) ~> 
		$.ajax {
			type: "post"
			url: "#{@config.root-url}api/#something"
			data: data
			success: successcb
			error: errorcb
		}
	login: (data, cb) ~> 
		@request "users/login?mail=#{data.mail}&password=#{data.pass}", (~> Toast "Success", "It worked! You're fucking logged in!"; cb!), ~> Toast "Error", "The mail/pass combination was a total fuckup"
	register: (data, cb) ~>
		@post "users/register", {mail: data.mail, password: data.pass}, (~> Toast "Success", "It worked! New account has been created!"; cb!), ~> Toast "Error", "The account could not be created"

window.Client = new Client()
angular.module AppInfo.displayname .value "Data", window.Client
module.exports = window.Client
