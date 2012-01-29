Ftp = require('../ftp')
ftpservers = require('./ftpservers')
should = require('should')
net = require('net')
ftpServer = {}

describe 'ftp.disconnect', ->

	before =>
		ftpServer = new ftpservers.MicrosoftFtpServer()
		ftpServer.open()
	after =>
		ftpServer.close()

	it 'should send QUIT and disconnect the connection', (done) ->
		ftp = new Ftp({port: 20021, username: "jsmith", password: "mypass"})
		ftp.connect (err) ->
			should.not.exist(err)
			ftp.disconnect ->
				ftp.lastCmd.should.equal "QUIT"
				ftp.client.on 'close', ->
					done()