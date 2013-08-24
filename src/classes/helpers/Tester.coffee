# Prefixes for some things like IndexedDB or RequestAnimationFrame
PREFIXES = ["moz", "webkit", "ms"]

# A list of tests to figure out how to run the app
TESTS =
	"indexeddb": ->
		# Checking whether the base indexedDB exists
		if window.indexedDB then return true
		
		# Else, check if one of the other ones are available
		return true for prefix in PREFIXES when window["#{prefix}IndexedDB"]?
		false
		
	"localstorage": -> chrome?.storage? or window.localDBStorage? # Only two things to check here : normal API and Chrome local DBStorage

	"chrome.storage": -> chrome? and chrome.storage?
	"webkitNotifications": -> webkitNotifications?
	"mac": -> (navigator.userAgent.indexOf "Macintosh") >= 0
	"requestAnimationFrame": -> 
		# Checking whether the base rAF exists
		if window.requestAnimationFrame then return true

		# Else, check if one of the other ones is available
		return true for prefix in PREFIXES when window["#{prefix}RequestAnimationFrame"]
		return false
	"mozNotification": -> Notification? or mozNotification?

# A list of functions that normalize some stuff relating to databases and stuff
NORMIALIZES =
	"indexeddb": -> unless window.indexedDB
		# These are the props that belong to indexedDB
		PROPS = ["IDBCursor", "IDBCursorWithValue", "IDBTransaction", "IDBDatabase", "IDBIndex", "IDBKeyRange", "IDBFactory", "IDBObjectStore", "IDBOpenDBRequest", "IDBRequest", "IDBVersionChangeEvent"]

		# Getting the right one and normalizing it
		for prop in PROPS
			window[prop] = window["#{prefix}#{prop}"] for prefix in PREFIXES when window["#{prefix}IndexedDB"]?

		# And finally indexedDB itself is normalized
		window.indexedDB = window["#{prefix}IndexedDB"] for prefix in PREFIXES when window["#{prefix}IndexedDB"]?

	"localstorage": ->
		# If running the app in a chrome packaged app, use chrome local localstorage
		window.LocalDBStorage = {}
		if chrome? and chrome.storage?
			window.LocalDBStorage.set = (key, value) -> chrome.storage.local.set key: value
			window.LocalDBStorage.get = (args...) -> chrome.storage.local.get.apply chrome.storage.local, args
			window.LocalDBStorage.remove = chrome.storage.local.remove
		# Else run the regular localstorage with a slightly different API
		else
			window.LocalDBStorage.set = (key, value) -> localDBStorage.setItem key, value
			window.LocalDBStorage.get = (item, callback) -> res = {}; res[item] = window.localDBStorage.getItem item; callback res
			window.LocalDBStorage.remove = (item) -> window.localDBStorage.removeItem item

	"requestAnimationFrame" : -> 
		if not window.requestAnimationFrame?
			return window.requestAnimationFrame = window["#{prefix}RequestAnimationFrame"] for prefix in PREFIXES when window["#{prefix}RequestAnimationFrame"]?

	"mozNotification": ->  window.Notification = window.mozNotification or window.Notification

# Finally wrapping them up in an object that runs the tests, runs the normalizes and makes the test results available
# Also, if a test was unsuccesful then the normalize function associated never runs
class Tester extends IS.Object
	constructor: -> @log "Tester Online"; do @tests; do @normalize
	tests: -> @[name] = do test for name, test of TESTS
	normalize: -> do normalize for name, normalize of NORMIALIZES

module.exports = Tester
