net = require('net')

module.exports = class Ftp

	LineFeed = "\n"
	CarriageReturn = "\r"

	constructor: (params) ->
		params ?= {}
		@host = params.host or= 'localhost'
		@username = params.username or= 'anonymous'
		@password = params.password or= 'anonymous'
		@port = params.port or= 21
		@authenticated = false
		@features = []
		@encoding = 'ascii'
		@existingLines = []

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
			@os = os[0].substr(4)
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
			#console.log "<" + data.toString() + ">"
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

	disconnect: (callback) ->
		@raw("QUIT")
		@client.end()
		callback()

	raw: (command, args...) ->
		args = args.join(" ")
		@lastCmd = command
		#console.log command + " " + args.trim() + ":"
		@client.write(command + " " + args.trim() + CarriageReturn + LineFeed, @encoding)

	processResponse: (data) ->
		done = false # Whether we can emit the data

		# Split the current data on line breaks
		lines = data.toString().split(LineFeed)

		# Remove blank lines, and push to the existing array
		for line in lines
			line = line.replace(CarriageReturn, "")
			@existingLines.push(line) if line != ""

		# Check to see if we've received the last line of this transmission
		if @existingLines.length > 1 and @existingLines[0].substr(0, 3) == @existingLines[@existingLines.length - 1].substr(0, 3)
			done = true
		
		# Or if this is the one and only line coming
		if @existingLines.length == 1 and @existingLines[0].substr(3, 1) != "-"
			done = true

		if done
			multiLine = (@existingLines.length > 1)
			respCode = parseInt(@existingLines[0].substr(0, 3))
			@client.emit(respCode, @existingLines, multiLine)
			@existingLines = []