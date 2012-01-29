Ftp = require('../ftp')
ftpservers = require('./ftpservers')
should = require('should')
net = require('net')
ftpServer = {}


describe 'ftp.connect', ->

	beforeEach ->
		ftpServer = new ftpservers.MicrosoftFtpServer()
		ftpServer.open()
	afterEach ->
		ftpServer.close()
		ftpServer = undefined

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

	it 'should get a list of features supported on the server', (done) ->
		ftp = new Ftp({port: 20021, username: "jsmith", password: "mypass"})
		ftp.connect (err) ->
			should.not.exist(err)
			("LANG EN*" in ftp.features).should.be.true
			("UTF8" in ftp.features).should.be.true
			("PBSZ" in ftp.features).should.be.true
			done()

	it 'should get a list of sub-features supported on the server', (done) ->
		ftp = new Ftp({port: 20021, username: "jsmith", password: "mypass"})
		ftp.connect (err) ->
			should.not.exist(err)
			("TLS" in ftp.features.auth).should.be.true
			("TLS-C" in ftp.features.auth).should.be.true
			("SSL" in ftp.features.auth).should.be.true
			("C" in ftp.features.prot).should.be.true
			("P" in ftp.features.prot).should.be.true
			done()

	it 'should be able to process data even with a lag coming across the network', (done) ->

		# Override the "FEAT" return to add a one-second delay across two socket writes
		ftpServer.feat = ->
			ftpServer.socket.write("211-Extended features supported:\r\n LANG EN*\r\n UTF8\r\n AUTH TLS;TLS-C;SSL;TLS-P;\r\n")
			setTimeout ->
				ftpServer.socket.write(" PBSZ\r\n PROT C;P;\r\n CCC\r\n HOST\r\n SIZE\r\n MDTM\r\n REST STREAM\r\n211 END\r\n")
			, 500
			 

		ftp = new Ftp({port: 20021, username: "jsmith", password: "mypass"})
		ftp.connect (err) ->
			should.not.exist(err)
			("LANG EN*" in ftp.features).should.be.true
			("UTF8" in ftp.features).should.be.true
			("PBSZ" in ftp.features).should.be.true
			done()

	it 'should set the encoding to UTF8 if supported', (done) ->
		ftp = new Ftp({port: 20021, username: "jsmith", password: "mypass"})
		ftp.connect (err) ->
			should.not.exist(err)
			ftp.encoding.should.equal "utf8"
			done()


