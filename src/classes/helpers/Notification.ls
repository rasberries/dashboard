const DRIVERS = [\webkit \normal \firefox]; Drivers = new IS.Enum DRIVERS

class NotificationHelper extends IS.Object
	~> 
		Runtime.init 'toast-driver', \number
		Runtime.init 'toast-timeout', \number

		timeout <~ DBStorage.get "toast-timeout"
		timeout ?= 5000

		Runtime.set 'toast-timeout', timeout
		Runtime.set 'toast-driver',	Drivers[\normal]
		if Tester[\webkitNotifications]
			unless Tester[\chrome.storage]
				handler = ->
					webkitNotifications.requestPermission()
					window.removeEventListener "click"
				window.addEventListener "click", handler
			Runtime.set 'toast-driver', Drivers[\webkit]
		else if Tester[\mozNotification]
			handler = ~> 
				Notification.requestPermission ~> @log it
				window.removeEventListener 'click', handler
			window.addEventListener 'click', handler
			Runtime.set 'toast-driver', Drivers[\firefox]
		@echo "Notification Helper Online, with driver : ", @drive, " and timeout : ", Runtime.get('toast-timeout')

	toast: (title = "Notification", ...body)~> switch Runtime.get('toast-driver')
	| Drivers.webkit => 
		if webkitNotifications.checkPermission() is 0 
			@toast-webkit title, body 
		else @toast-normal title, body
	| Drivers.firefox => 
		if Notification.permission in <[granted default]>
			@toast-firefox title, body
		else @toast-normal title, body
	| otherwise => @toast-normal title, body
	toast-webkit: (title, body)~>
		b = body.shift!
		for item in body then b += "\n#item"
		notif = webkitNotifications.createNotification 'icon.ico', title, b 
		notif.ondisplay = (ev) -> setTimeout (-> ev.currentTarget.cancel()), Runtime.get 'toast-timeout'
		notif.show!
	toast-firefox: (title, body) ~>
		b = body.shift!
		for item in body then b += "\n#item"
		notif = new Notification title, dir: 'auto', lang: 'en-US', body: b, icon: 'icon.ico'
		notif.onshow = (ev) -> setTimeout (-> ev.currentTarget.cancel()), Runtime.get 'toast-timeout'
	toast-normal: (title, body) ~>
		b = ""
		if Modal? 
			for item in body then b += "<p>#item</p>"
			Modal.show {title: title, content: b}, Runtime.get 'toast-timeout'
		else 
			b = ( [title] ++ body ) * "\n"
			alert b

Helper = new NotificationHelper()
Toast = Helper.toast
module.exports = [ Helper, Toast ]
