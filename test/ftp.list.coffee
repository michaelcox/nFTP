Ftp = require('../index')
ftpservers = require('./ftpservers')
should = require('should')
net = require('net')
ftpServer = {}

describe 'ftp.list', ->

	beforeEach ->
		ftpServer = new ftpservers.MicrosoftFtpServer()
		ftpServer.open()
	afterEach ->
		ftpServer.close()
		ftpServer = undefined

	it 'should return an array of objects with a filename attribute', (done) ->
		ftp = new Ftp({port: 20021, username: "jsmith", password: "mypass"})
		ftp.connect (err) ->
			ftp.list (err, list) ->
				should.exist list
				done()