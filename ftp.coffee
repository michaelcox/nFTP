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

		@client.once 'authenticated', =>
			@authenticated = true
			@raw("SYST")

		@client.once 'invalidLogin', ->
			passToCallback(new Error("Invalid Login"))

		@client.once 'user', =>
			@raw("USER", @username)

		@client.once 'pass', =>
			@raw("PASS", @password)

		@client.once 'os', (@os) =>
			passToCallback()

		@client.once 'error', (err) ->
			passToCallback(err)

		@client.on 'data', (data) =>
			@processResponse(data)

		passToCallback = (err) =>
			# Remove all the listeners that were created for the "connect" function
			@client.removeAllListeners('user')
			@client.removeAllListeners('pass')
			@client.removeAllListeners('os')
			@client.removeAllListeners('authenticated')
			@client.removeAllListeners('invalidLogin')
			@client.removeAllListeners('error')

			callback(err)

	raw: (command, arg1, arg2, arg3) ->
		args = [arg1, arg2, arg3].join(" ")
		@lastCmd = command
		@client.write(command + " " + args)

	processResponse: (data) ->
		respCode = parseInt(data.toString().substring(0, 3))
		text = data.toString().substring(4)
		@handleResponse(respCode, text)

	handleResponse: (respCode, text) ->
		#console.log respCode
		switch respCode
			when 215 then @client.emit('os', text)
			when 220 then @client.emit('user')
			when 331 then @client.emit('pass')
			when 230 then @client.emit('authenticated')
			when 530 then @client.emit('invalidLogin', new Error("Invalid Login"))
  