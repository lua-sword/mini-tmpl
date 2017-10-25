local tmpl = require "tmpl"

local prep = tmpl.prepare
local t_item = prep("- !{1}\n")
local t_items = prep([[!{v_items>t_item}]])

assert(t_item.tag=="template")
assert(t_items.tag=="template")

local data = {
	v_items = {
		"line 1",
		"line 2",
		"line 3",
	},
}
local templates={t_item=t_item}

local b = tmpl.render(t_items, data, templates)
io.stdout:write(b)
