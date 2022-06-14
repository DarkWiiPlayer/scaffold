# Scaffold

**Directory structure scaffolding in Lua**

This library offers a collection of helpers to quickly build custom project scaffolding into Lua projects by turning table structures into directory structures.

## Examples

### Building a Directory

```lua
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
```