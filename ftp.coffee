net = require('net')

module.exports = class Ftp

	CRLF = "\r\n"

	constructor: (params) ->
		params ?= {}
		@host = params.host or= 'localhost'
		@username = params.username or= 'anonymous'
		@password = params.password or= 'anonymous'
		@port = params.port or= 21
		@authenticated = false
		@features = []
		@encoding = 'ascii'

	connect: (callback) ->
		# Step 1: Connect
		@client = net.connect @port, @host

		# Step 2: Set the initial encoding of the connection
		@client.setEncoding(@encoding)

		# Step 3: Send Username
		@client.once 'user', =>
			@raw("USER", @username)

		# Step 4: Send Password
		@client.once 'pass', =>
			@raw("PASS", @password)
		
		# Step 5: Send SYST command to get Operating System of Server
		@client.once 'authenticated', =>
			@authenticated = true
			@raw("SYST")

		# Step 6: Send FEAT command to get extended FTP features available on server
		@client.once 'syst', (@os) =>
			@raw("FEAT")

		# Step 7: Parse the feature list, which comes back in multiple connections
		@client.on 'feat', (feat) =>
			featLines = feat.split(CRLF)
			for line in featLines
				if line.substring(0, 1) is " "
					if line.substring(1, 5) in ["AUTH", "PROT"]
						subitems = line.substring(6).split(";")
						name = line.substring(1, 5).toLowerCase()
						@features[name] = []
						for subitem in subitems
							@features[name].push(subitem)
					else
						@features.push(line.substring(1))
			setEncoding()

		# Step 8: If supported, set the encoding to UTF-8
		setEncoding = =>
			if ("UTF8" in @features)
				@raw("OPTS", "UTF8 ON")
			else
				passToCallback()

		# Step 9: Call Callback if options were set
		@client.once 'success', =>
			@encoding = 'utf8'
			passToCallback()

		# Handle Invalid Login error
		@client.once 'invalidLogin', ->
			passToCallback(new Error("Invalid Login"))
			
		# Handle any other errors raised by the connection
		@client.once 'error', (err) ->
			passToCallback(err)

		# Establish a function to handle any data that comes across the wire
		@client.on 'data', (data) =>
			@processResponse(data)

		# Remove all the listeners that were created for the "connect" function
		passToCallback = (err) =>
			@client.removeAllListeners('user')
			@client.removeAllListeners('pass')
			@client.removeAllListeners('syst')
			@client.removeAllListeners('feat')
			@client.removeAllListeners('success')
			@client.removeAllListeners('authenticated')
			@client.removeAllListeners('invalidLogin')
			@client.removeAllListeners('error')

			@client.setEncoding(@encoding)

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
			when 200 then @client.emit('success', text)
			when 211 then @client.emit('feat', text)
			when 215 then @client.emit('syst', text)
			when 220 then @client.emit('user')
			when 331 then @client.emit('pass')
			when 230 then @client.emit('authenticated')
			when 530 then @client.emit('invalidLogin', new Error("Invalid Login"))
  