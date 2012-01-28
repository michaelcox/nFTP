net = require('net')

module.exports = class Ftp

	constructor: (params) ->
		params ?= {}
		@host = params.host or= 'localhost'
		@username = params.username or= 'anonymous'
		@password = params.password or= 'anonymous'
		@port = params.port or= 21
		@authenticated = false

	connect: (callback) ->
		@client = net.connect @port, @host

		@client.on 'authenticated', =>
			@authenticated = true
			callback()

		@client.on 'error', (err) ->
			callback(err)

		@client.on 'data', (data) =>
			@processResponse(data)

	raw: (command, arg1, arg2, arg3) ->
		args = [arg1, arg2, arg3].join(" ")
		@lastCmd = command
		@client.write(command + " " + args)

	processResponse: (data) ->
		respCode = parseInt(data.toString().substring(0, 3))
		text = data.toString().substring(3)
		@handleResponse(respCode, text)

	handleResponse: (respCode, text) ->
		#console.log respCode
		switch respCode
			when 220 then @raw("USER", @username)
			when 331 then @raw("PASS", @password)
			when 230 then @client.emit('authenticated')
			when 530 then @client.emit('error', new Error("Invalid Login"))
  