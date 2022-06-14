package = "scaffold"
version = "dev-1"
source = {
	url = "git+https://github.com/darkwiiplayer/scaffold"
}
description = {
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
	}
}
