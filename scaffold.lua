--- A collection of functions that write things to a directory

local lfs = require 'lfs'

local scaffold = {}

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
		elseif value==true then
			scaffold.file("", path)
		elseif value==false then
			scaffold.delete(path)
		else
			error("Unknown type at "..path)
		end
	end
end

--- Reads a directory into a table
function scaffold.readdir(path)
	local mode = lfs.attributes(path, 'mode')
	if mode == 'directory' then
		local result = {}
		for name in lfs.dir(path) do
			if name:sub(1, 1) ~= '.' then
				result[name] = scaffold.readdir(path.."/"..name)
			end
		end
		return result
	elseif mode == 'file' then
		return(io.open(path, 'rb'):read('a'))
	end
end

return scaffold
