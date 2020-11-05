local tmpl = require "mini-tmpl"

local t_item  = tmpl.prepare "- !{1}\n"
local t_items = tmpl.prepare [[!{v_items>t_item}]]

local data = {
	v_items = {
		"line 1",
		"line 2",
		"line 3",
	},
}
local templates={[1]=t_items, t_item=t_item}

local r = tmpl.render(templates, data)
io.stdout:write(r)
assert(r=="- line 1\n- line 2\n- line 3\n")
print("ok")
