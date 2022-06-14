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
		it "returns an error when it can't create a file", ->
			assert.is.nil scaffold.file("", "")
			assert.is.string select 2, scaffold.file("", "")

	describe 'buildpath', ->
		it 'creates flat directories', ->
			scaffold.buildpath 'test/foo'
			assert.truthy io.open('test/foo/file', 'wb')
		it 'creates deep directories', ->
			scaffold.buildpath 'test/foo/bar'
			assert.truthy io.open('test/foo/bar/file', 'wb')

	describe 'delete', ->
		it 'deletes empty directories', ->
			scaffold.buildpath 'test/foo'
			scaffold.delete 'test/foo'
			assert.falsy io.open("test/foo/file", "wb")
		it 'deletes non-empty directories', ->
			scaffold.buildpath 'test/foo'
			scaffold.file 'Hello, World!', 'test/foo/file'
			scaffold.delete 'test/foo'
			assert.falsy io.open("test/foo/file", "wb")
		it 'deletes files', ->
			scaffold.file 'Hello, World!', 'test/file'
			scaffold.delete 'test/file'
			assert.falsy io.open("test/file", "rb")

	describe 'builddir', ->
		it 'creates directories', ->
			scaffold.builddir 'test', foo: {}
			assert.truthy io.open('test/foo/file', 'wb')
		it 'creates files from strings', ->
			scaffold.builddir 'test', file: "Hello, World!"
			assert.equal "Hello, World!", assert(io.open('test/file', 'rb'))\read("*a")
		it 'creates files from buffers', ->
			scaffold.builddir 'test', file: {"foo", "bar"}
			assert.equal "foobar", assert(io.open('test/file', 'rb'))\read("*a")
		it 'touches files', ->
			scaffold.builddir 'test', file: true
			assert.equal "", assert(io.open('test/file', 'rb'))\read("*a")
		it 'remove files', ->
			scaffold.file 'Hello', 'test/file'
			scaffold.builddir 'test', file: false
			assert.nil io.open('test/file', 'rb')
		it 'errors when not passed a table', ->
			assert.errors ->
				scaffold.builddir 'EEEEEEEEE'

	describe 'readdir', ->
		it 'reads directories and files', ->
			for dir in *{
				{ foo: "bar" }
				{ foo: { bar: "baz" } }
			}
				scaffold.delete 'test'
				scaffold.builddir 'test', dir
				assert.same dir, scaffold.readdir 'test'
