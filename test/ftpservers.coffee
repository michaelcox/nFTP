net = require('net')

exports.MicrosoftFtpServer = class FtpServer

	constructor: ->
		# Do nothing for now

	open: ->
		self = this
		@server = net.createServer()
		@server.listen(20021)

		@server.on 'connection', (socket) ->
			self.socket = socket
			self.welcome()
			socket.on 'data', (data) ->
				dataSent = data.toString()
				#console.log dataSent
				[cmd, args...] = dataSent.split(" ")

				switch cmd
					when "USER" then self.user(args[0])
					when "PASS" then self.pass(args[0])
					when "SYST" then self.syst()

	close: ->
		@server.close()

	user: (@username) =>
		@socket.write("331 Password required for #{username}.")

	pass: (@password) =>
		if @username is 'jsmith' and @password is 'mypass'
			@socket.write("230-Welcome")
			@socket.write("230 User logged in.")
		else
			@socket.write("530 Login incorrect. You sent: " + @username + " " + @password)

	syst: ->
		@socket.write("215 Windows_NT")

	welcome: ->
		@socket.write('220-Microsoft FTP Service')
		@socket.write('220 Example.com FTP')
