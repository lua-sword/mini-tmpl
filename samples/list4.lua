local tmpl = require "mini-tmpl"

local templates = { 
	tmpl.prepare [[!{1>2}]],
	tmpl.prepare [[- !{1}!{^l}]],
}

local data = {
	{
		"line 1",
		"line 2",
		"line 3",
	},
	l="\n",
}

local r = tmpl.render(templates, data)
io.stdout:write(r)
assert(r=="- line 1\n- line 2\n- line 3\n")
print("ok")
