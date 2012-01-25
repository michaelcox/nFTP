module.exports = class Ftp

	constructor: (params) ->
		params ?= {}
		@host = params.host if params.host?
		@username = params.username if params.username?
		@password = params.password if params.password?
		@port = params.port if params.port?

	# Default connection params	
	host: 'localhost'
	username: 'anonymous'
	password: 'anonymous'
	port: 21

	connect: (callback) ->
		return "ok"
  