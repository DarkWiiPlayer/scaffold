# Scaffold

**Directory structure scaffolding in Lua**

This library offers a collection of helpers to quickly build custom project scaffolding into Lua projects by turning table structures into directory structures.

## Documentation

Clone the project and run `ldoc` to generate the documentation
or view it online at [darkwiiplayer.github.io/scaffold](https://darkwiiplayer.github.io/scaffold/).

## Examples

### Building a Directory

	local scaffold = require 'scaffold'

	scaffold.builddir {
		subdir = {
			empty_file = true;
			text_file = "Hello, World!";
		};
		delete_me = false; -- Will be deleted if it exists
		text_file = {
			-- Sequences get written recursively
			"line 1\n",
			"line 2\n",
			{ _VERSION, " says hi" },
		};
	}

This will populate an empty directory like this:

	$ tree
	.
	├── subdir
	│   ├── empty_file
	│   └── text_file
	└── text_file

	$ cat text_file 
	line 1
	line 2
	Lua 5.4 says hi

## Commandline tool

Scaffold also provides a simple commandline tool to generate directories.

The tool is called as `scaffold <name> ...args`, where `name` is the name of a
Lua submodule that gets required as `require("scaffold."..name)`.

The module can either directly return a table to be turned into a directory, or
a function that gets called with all the extra commandline arguments after the
module name.

To load scaffold modules from directories that shouldn't otherwise be available
to Lua, the environment variable `SCAFFOLD_DIR` can be used. This variable can
contain a semicolon-separated list of directories that will be prepended to
`package.path` at the start of the script.

Note that this variable should only contain paths to the library folder, and
scaffold will add the `?.lua` and `?/init.lua` parts that `package.path`
expects.
