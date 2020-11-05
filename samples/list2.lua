local tmpl = require "mini-tmpl"

local templates = {
	main = tmpl.prepare([[!{items>item}]]),
	item = tmpl.prepare([[- !{1}!{^l}]]),
}

local data = {
	items = {
		"line 1",
		"line 2",
		"line 3",
	},
	l="\n",
}

local b = tmpl.render(templates, data, {main="main"})
io.stdout:write(b)
assert(b=="- line 1\n- line 2\n- line 3\n")
print("ok")
