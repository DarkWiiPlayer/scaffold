package = "scaffold"
version = "dev-2"
source = {
	url = "git+https://github.com/darkwiiplayer/scaffold"
}
description = {
	summary = "A library to assemble directory structures from Lua tables",
	homepage = "https://github.com/darkwiiplayer/scaffold",
	license = "Unlicense"
}
dependencies = {
	"lua ~> 5, >= 5.1"
}
build = {
	type = "builtin",
	modules = {
		scaffold = "scaffold.lua"
	},
	install = {
		bin = {
			"bin/scaffold"
		}
	}
}
