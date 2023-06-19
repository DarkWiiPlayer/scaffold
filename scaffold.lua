--- A collection of functions that write things to a directory
-- @module scaffold

local lfs = require 'lfs'

local scaffold = {}

scaffold.lazy = setmetatable({
	__tostring = function(self)
		if not self.contents then
			local iotype = io.type(self.file)
			if iotype == "file" then
				self.file:seek("set", 0)
				self.contents = self.file:read("*a")
			elseif iotype == "closed file" then
				error("Attempting to read closed file handle")
			else
				error("field 'file' is not a file handle")
			end
		end
		return self.contents
	end
}, {
	-- note: checking the metatable against `scaffold.lazy` further down; don't change that
	__call = function(self, path)
		return setmetatable({file=io.open(path)}, self)
	end
})

--- Helper function to avoid messy indentation in source files.
-- Removes whitespace up to and including the first non-whitespace character at the beginning of every line.
-- @tparam string input A multiline string to remve indentation from.
-- @usage
-- scaffold.unindent [[
-- 	|-- This file was generated automatically
-- 	|function do_things()
-- 	|	print "This Lua file is nicely formatted"
-- 	|end
-- ]]
function scaffold.unindent(input)
	if type(input) ~= "string" then
		error("Expected string, got "..type(input))
	end
	return input:gsub("[^\n]+", function(line)
		return line:gsub("^%s*[^%s]", "")
	end)
end

--- Creates a directory and all necessary parent directories.
function scaffold.buildpath(path)
	local slash = 0
	while slash do
		slash = path:find("/", slash+1)
		lfs.mkdir(path:sub(1, slash))
	end
end

--- Deletes a file or directory recursively
-- @tparam string path The path to the file or directory to delete
function scaffold.delete(path)
	path = path:gsub('/+$', '')
	local mode = lfs.attributes(path, 'mode')
	if mode=='directory' then
		for entry in lfs.dir(path) do
			if not entry:match("^%.%.?$") then
				scaffold.delete(path..'/'..entry)
			end
		end
	end
	os.remove(path)
end

--- Writes an arbitrarily nested sequence of strings to a file
-- @param buffer A string or nested sequence of strings to be written.
-- @tparam file file A file to write to (can be string or object with `write` method).
-- @treturn number The number of bytes that were written
function scaffold.file(buffer, file)
	local bytes = 0
	local close = false
	if type(file) == "string" then
		local err
		file, err = io.open(file, "wb")
		if not file then
			return nil, err
		end
		close = true
	end
	if type(buffer) == "string" then
		file:write(buffer)
		bytes = #buffer
	else
		for _, chunk in ipairs(buffer) do
			bytes = bytes + scaffold.file(chunk, file)
		end
	end
	if close then
		file:close()
	end
	return bytes
end

--- Builds a directory structure recursively from a table template.
-- @tparam[opt="."] string prefix A prefix to the path, aka. where to initialize the directory structure.
-- @tparam table tab A table representing the directory structure.
-- Table entries are subdirectories, strings are files, false means delete,
-- true means touch file, everything else is an error.
-- @usage
-- 	builddir {
-- 		sub_dir = {
-- 			file = 'Hello World!'; -- new file
-- 		}
-- 		empty = true; -- new empty file
-- 		delete_me = false; -- will be deleted
-- 	}
function scaffold.builddir(prefix, tab)
	-- Prefix is optional
	if not tab then
		tab = prefix
		prefix = '.'
	end

	if lfs.attributes(prefix, 'mode') ~= "directory" then
		scaffold.buildpath(prefix)
	end

	if type(tab) ~= 'table' then
		error("Invalid argument; expected table, got "..type(tab), 1)
	end

	for path, value in pairs(tab) do
		if prefix then
			path = prefix.."/"..tostring(path)
		end
		if type(value) == "table" then
			if value[1] then
				scaffold.file(value, path)
			else
				if lfs.attributes(path, 'mode') ~= "directory" then
					local result, err = lfs.mkdir(path)
					if not result then
						error("Building "..path..":"..err)
					end
				end
				scaffold.builddir(path, value)
			end
		elseif type(value) == "string" then
			scaffold.file(value, path)
		elseif getmetatable(value) == scaffold.lazy then
			scaffold.file(tostring(value), path)
		elseif value==true then
			scaffold.file("", path)
		elseif value==false then
			scaffold.delete(path)
		else
			error("Unknown type at "..path)
		end
	end
end

--- Controls the behaviour of `scaffold.readdir`.
-- @table read_options
-- @field[opt=nil] files How to treat files
-- @tfield[opt=false] boolean hidden Whether to include display hidden files

--- Reads a directory into a table.
-- @tparam string path The path to the file or directory to read
-- @tparam[opt={}] table opt Options table conformign to `read_options`
function scaffold.readdir(path, options)
	local mode = lfs.attributes(path, 'mode')
	local files = options and options.files
	local hidden = options and options.hidden
	if mode == 'directory' then
		local result = {}
		local success, iter,state = pcall(lfs.dir, path)
		if success then
			for name in iter,state do
				if name ~= '.' and name ~= '..' then
					if hidden or name:sub(1,1) ~= "." then
						result[name] = scaffold.readdir(path.."/"..name, options)
					end
				end
			end
		end
		return result
	elseif mode == 'file' then
		if files == false then
			return
		elseif files == "handle" then
			return io.open(path, 'rb')
		elseif files == "lazy" then
			return scaffold.lazy(path)
		elseif files == true then
			return true
		else
			return(io.open(path, 'rb'):read('a'))
		end
	end
end

--- Reads or writes a value in a nested table at a given path
function scaffold.deep(object, path, ...)
	if type(path) == "table" then
		if #path == 0 then
			error("Attempt to index with empty path", 2)
		end
		for i=1, #path-1 do
			if object[path[i]] then
				object = object[path[i]]
			else
				object[path[i]] = {}
				object = object[path[i]]
			end
		end
		local last = path[#path]
		if select('#', ...) == 0 then
			return object[last]
		else
			object[last] = (...)
		end
	else
		local new = {}
		for fragment in string.gmatch(path, "[^/]+") do
			table.insert(new, fragment)
		end
		return scaffold.deep(object, new, ...)
	end
end

return scaffold
