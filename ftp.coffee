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

		# Step 3: Service ready for new user.
		@client.once 220, =>
			@raw("USER", @username)

		# Step 4: Username okay, need password.
		@client.once 331, =>
			@raw("PASS", @password)
		
		# Step 5: User logged in, proceed. Send SYST command to get Operating System of Server
		@client.once 230, =>
			@authenticated = true
			@raw("SYST")

		# Step 6: Got SYST, Send FEAT command to get extended FTP features available on server
		@client.once 215, (os) =>
			@os = os[0]
			@raw("FEAT")

		# Step 7: Parse the feature list, which comes back in multiple connections
		@client.on 211, (featLines) =>
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
		@client.once 200, =>
			@encoding = 'utf8'
			passToCallback()

		# Handle Invalid Login error
		@client.once 530, ->
			passToCallback(new Error("Invalid Login"))
			
		# Handle any other errors raised by the connection
		@client.once 'error', (err) ->
			passToCallback(err)

		# Establish a function to handle any data that comes across the wire
		@client.on 'data', (data) =>
			@processResponse(data)

		passToCallback = (err) =>
			# Remove all the listeners that were created for the "connect" function
			@client.removeAllListeners()

			# Re-add this listener for future processing
			@client.on 'data', (data) =>
				@processResponse(data)

			# In case it changed, set the encoding of the connection
			@client.setEncoding(@encoding)

			callback(err)

	raw: (command, args...) ->
		args = args.join(" ")
		@lastCmd = command
		@client.write(command + " " + args)

	processResponse: (data) ->
		respCode = parseInt(data.toString().substring(0, 3))
		text = data.toString().substring(4).split(CRLF)
		multiLine = (text.length > 1)
		@client.emit(respCode, text, multiLine)