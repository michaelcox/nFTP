Ftp = require('../ftp')

describe 'ftp constructor', ->
	it 'should accept connection params', ->
		params = {}
		params.host = "ftp.example.com"
		params.username = "user"
		params.password = "user-password"
		params.port = 22
		app = new Ftp(params)
		app.host.should.equal "ftp.example.com"
		app.username.should.equal "user"
		app.password.should.equal "user-password"
		app.port.should.equal 22

	it 'should use defaults if no params specified', ->
		app = new Ftp() # Passing no params
		app.host.should.equal "localhost"
		app.username.should.equal "anonymous"
		app.password.should.equal "anonymous"
		app.port.should.equal 21

	it 'should accept a mix of specified and default params', ->
		params = {}
		params.host = "ftp.example.com"
		params.username = "user"
		params.password = "user-password"
		app = new Ftp(params)
		app.host.should.equal "ftp.example.com"
		app.username.should.equal "user"
		app.password.should.equal "user-password"
		app.port.should.equal 21