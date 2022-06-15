# Scaffold

**Directory structure scaffolding in Lua**

This library offers a collection of helpers to quickly build custom project scaffolding into Lua projects by turning table structures into directory structures.

## Documentation

Clone the project and run `ldoc` to generate the documentation.

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
