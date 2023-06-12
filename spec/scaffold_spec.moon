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
		dir = { foo: { bar: "baz" } }
		before_each -> scaffold.builddir 'test', dir
		after_each -> scaffold.delete 'test'
		it 'reads directories and files', ->
			assert.same dir, scaffold.readdir 'test'
		it 'skips files when requested', ->
			loaded = scaffold.readdir 'test', files: false
			assert.is.nil loaded.foo.bar
		it 'loads files as true when requested', ->
			loaded = scaffold.readdir 'test', files: true
			assert.is.true loaded.foo.bar
		it 'returns file handles when requested', ->
			loaded = scaffold.readdir 'test', files: 'handle'
			assert.equal 'file', io.type loaded.foo.bar
		it 'lazy loads files when requested', ->
			loaded = scaffold.readdir 'test', files: 'lazy'
			assert.is.table loaded.foo.bar
			assert.equal "baz", tostring(loaded.foo.bar)
		it 'ignores hidden files by default', ->
			scaffold.builddir "test", { ".hidden": { ".foo": "secret" } }
			assert.same dir, scaffold.readdir 'test'
			assert.same { ".foo": "secret" }, scaffold.readdir('test', hidden: true)[".hidden"]
	
	describe 'unindent', ->
		it 'removes spaces', ->
			assert.equal "foo", scaffold.unindent "  #foo"
		it 'preserves spaces after character', ->
			assert.equal " foo", scaffold.unindent "  # foo"
		it 'removes tabs', ->
			assert.equal "foo", scaffold.unindent "	#foo"
		it 'handles mixed indentation', ->
			assert.equal "foo", scaffold.unindent "	 #foo"
		it 'handles several lines', ->
			assert.equal "foo\n	bar\nbaz", scaffold.unindent "	|foo\n	|	bar\n	|baz"

	describe 'deep', ->
		describe 'with table path', ->
			it 'reads from tables', ->
				t = { foo: 10, bar: { baz: 20 } }
				assert.equal 10, scaffold.deep t, { "foo" }
				assert.equal 20, scaffold.deep t, { "bar", "baz" }
			it 'inserts into tables', ->
				t = {}
				scaffold.deep t, {'foo'}, 10
				assert.equal 10, t.foo
			it 'deletes from tables', ->
				t = { foo: 10 }
				scaffold.deep t, { 'foo' }, nil
				assert.nil t.foo
			it 'fails for empty path', ->
				assert.errors ->
					scaffold.deep {}, {}, 10
		describe 'with string path', ->
			it 'reads from tables', ->
				t = { foo: 10, bar: { baz: 20 } }
				assert.equal 10, scaffold.deep t, "foo"
				assert.equal 20, scaffold.deep t, "bar/baz"
			it 'inserts into tables', ->
				t = {}
				scaffold.deep t, 'foo', 10
				assert.equal 10, t.foo
			it 'fails for empty path', ->
				assert.errors ->
					scaffold.deep {}, '', 10
