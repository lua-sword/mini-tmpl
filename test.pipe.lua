local tmpl = require "mini-tmpl"
local mkast = require "mini-tmpl.mkast"


--local a = tmpl.prepare("!{foo|f1|f2}")
local templates = {
	mkast.pipe(
		tmpl.prepare("!{foo}"),
		mkast.getf("f1"),
		mkast.getf("f2")
	)
}
local functions = {
	f1 = function(...) return ... end,
	f2 = function(...) return ... end,
}
local data = {
	foo = "FOO",
}
print(require"tprint"(templates[1],{inline=false}))
local r = tmpl.render(templates, data, functions)
print(r)
--assert(r=="hello world!")
