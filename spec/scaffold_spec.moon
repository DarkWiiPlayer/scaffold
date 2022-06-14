scaffold = require 'scaffold'

describe 'scaffold', ->
	before_each -> scaffold.buildpath 'test'
	after_each -> scaffold.delete 'test'

	describe 'file', ->
		it 'creates a file when given a string', ->
			scaffold.file("", "test/foo")
			assert.truthy io.open('test/foo')
		it 'writes a string to a file', ->
			scaffold.file("Hello, World!", "test/foo")
			assert.equal "Hello, World!", assert(io.open('test/foo'))\read("*a")
		it 'writes a sequence to a file', ->
			scaffold.file({"Hello, ", "World!"}, "test/foo")
			assert.equal "Hello, World!", assert(io.open('test/foo'))\read("*a")
		it 'writes a nested sequence to a file', ->
			scaffold.file({"Hello, ", {"World!"}}, "test/foo")
			assert.equal "Hello, World!", assert(io.open('test/foo'))\read("*a")

	describe 'buildpath', ->
		it 'creates flat directories', ->
			scaffold.buildpath 'test/foo'
			assert.truthy io.open('test/foo/file', 'wb')
		it 'creates deep directories', ->
			scaffold.buildpath 'test/foo/bar'
			assert.truthy io.open('test/foo/bar/file', 'wb')

	pending 'delete', ->
	pending 'builddir', ->
	pending 'readdir', ->
