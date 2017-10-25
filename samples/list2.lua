local tmpl = require "tmpl"

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
