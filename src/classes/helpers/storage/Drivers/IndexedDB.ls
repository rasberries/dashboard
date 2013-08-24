const DB_NAME = "tadpole"
const DB_STORE = "storage"
const DB_VERSION = 3
class IndexedDBDriver extends IS.Object
	(@loaded-database) ~> @init!open-database!
	get: (key, callback)~>
		unless @db then return @log "DB NOT READY"
		trans = @db.transaction [DB_STORE], \readonly
		store = trans.object-store DB_STORE
		req = store.get key
		req.onsuccess = ~> 
			rez = null; if it.target.result and it.target.result.value then rez = it.target.result.value
			callback rez
		req.onerror = ~> throw new Error "Could not get item #key"
		@
	set: (key, value) ~>
		unless @db then return @log "DB NOT READY"
		trans = @db.transaction [DB_STORE], \readwrite
		store = trans.object-store DB_STORE
		req = store.put value: value, key: key
		req.onsuccess = ~> @log "Successfuly saved #key as #value"
		req.onerror = ~> throw new Error "Could not save #key as #value"
		@
	remove: (key) ~>
		unless @db then return @log "DB NOT READY"
		trans = @db.transaction [DB_STORE], \readwrite
		store = trans.object-store DB_STORE
		req = store.delete key
		req.onsuccess = ~> @log "Successfuly deleted #key"
		req.onerror = ~> throw new Error "Could not delete item #key"
		@
	open-database: ~>
		req = indexedDB.open DB_NAME, DB_VERSION
		req.onsuccess = @success-event
		req.onerror = @error-event
		req.onupgradeneeded = @upgrade-event
	init: ~> @db = null; @
	success-event: ~> @db = it.target.result; @loaded-database!
	error-event: ~> @log "Database Error : ", it
	upgrade-event: ~>
		db = it.target.result
		it.target.transaction.error = @error-event
		if db.object-store-names.contains DB_STORE then db.delete-object-store DB_STORE
		store = db.create-object-store DB_STORE, key-path: \key
module.exports = IndexedDBDriver
