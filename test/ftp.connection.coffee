Ftp = require('../ftp')
should = require('should')
net = require('net')
server = {}

describe 'ftp.connect', ->

	before ->
		server = net.createServer()
		server.listen(20021)
		
		server.on 'connection', (socket) ->
			socket.write('220-Microsoft FTP Service')
			socket.write('220 Example.com FTP')
			socket.on 'data', (data) ->
				dataSent = data.toString()
				#console.log dataSent
				[cmd, args...] = dataSent.split(" ")

				switch cmd
					when "USER"
						@user = args[0]
						socket.write("331 Password required for #{args[0]}.")
					when "PASS"
						@pass = args[0]
						if @user is 'jsmith' and @pass is 'mypass'
							socket.write("230-Welcome")
							socket.write("230 User logged in.")
						else
							socket.write("530 Login incorrect. You sent: " + @user + " " + @pass)
					when "SYST" then socket.write("215 Windows_NT")

	after ->
		server.close()

	it 'should automatically authenticate upon successful connection', (done) ->
		ftp = new Ftp({port: 20021, username: "jsmith", password: "mypass"})
		ftp.connect (err) ->
			should.not.exist(err)
			ftp.authenticated.should.be.true
			done()

	it 'should call callback with Error object if unable to connect', (done) ->

		ftp = new Ftp({port: 20022}) #Invalid Port
		ftp.connect (err) ->
			err.should.be.instanceof Error
			done()

	it 'should call callback with Error object if invalid login', (done) ->
		ftp = new Ftp({port: 20021, username: "wrong", password: "wrong"})
		ftp.connect (err) ->
			err.should.be.instanceof Error
			ftp.authenticated.should.be.false
			err.message.should.equal "Invalid Login"
			done()

	it 'should detect system OS upon successful connection', (done) ->
		ftp = new Ftp({port: 20021, username: "jsmith", password: "mypass"})
		ftp.connect (err) ->
			should.not.exist(err)
			ftp.os.should.equal "Windows_NT"
			done()


