local tmpl = require "mini-tmpl"

local prep = tmpl.prepare
local templates = {}
templates.item = prep([[- !{1}!{^l}]])
local main = prep([[!{items>item}]])

local data = {
	items = {
		"line 1",
		"line 2",
		"line 3",
	},
	l="\n",
}

local b = tmpl.render(main, data, templates)
io.stdout:write(b)
assert(b=="- line 1\n- line 2\n- line 3\n")
print("ok")
