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
				dataSent = data.toString().replace("\r\n", "")
				#console.log dataSent
				[cmd, args...] = dataSent.split(" ")

				switch cmd
					when "USER" then self.user(args[0])
					when "PASS" then self.pass(args[0])
					when "SYST" then self.syst()
					when "FEAT" then self.feat()
					when "OPTS" then self.opts(args)
					when "QUIT" then self.quit()

	close: ->
		@server.close()

	user: (@username) =>
		@write("331 Password required for #{username}.\r\n")

	pass: (@password) =>
		if @username is 'jsmith' and @password is 'mypass'
			@write("230-Welcome\r\n230 User logged in.\r\n")
		else
			@write("530 Login incorrect.\r\n")

	syst: ->
		@write("215 Windows_NT\r\n")

	feat: ->
		@write("211-Extended features supported:\r\n LANG EN*\r\n UTF8\r\n AUTH TLS;TLS-C;SSL;TLS-P;\r\n PBSZ\r\n PROT C;P;\r\n CCC\r\n HOST\r\n SIZE\r\n MDTM\r\n REST STREAM\r\n211 END\r\n")

	opts: (args) ->
		if (args[0] is "UTF8" and args[1] is "ON")
			@write("200 OPTS UTF8 command successful - UTF8 encoding now ON.\r\n")

	quit: ->
		@socket.end()

	welcome: ->
		@write('220-Microsoft FTP Service\r\n220 Example.com FTP\r\n')

	write: (text) ->
		#console.log "<" + text + ">"
		@socket.write(text)
