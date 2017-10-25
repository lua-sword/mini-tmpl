local tmpl = require "tmpl"
local prep = tmpl.prepare

local templates = { prep([[- !{1}!{^l}]]) }

local main = prep([[!{1>1}]])

local data = {l="\n", {
	"line 1",
	"line 2",
	"line 3",
}}

local b = tmpl.render(main, data, templates)
io.stdout:write(b)
