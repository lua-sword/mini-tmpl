local tmpl = require "mini-tmpl"
local prep = tmpl.prepare

local templates = {
	[1] = prep([[- !{1}!{^l}]])
}

local main = prep([[!{1>1}]])

local data = {}
data.l="\n"

data[1] = {
	"line 1",
	"line 2",
	"line 3",
}

local b = tmpl.render(main, data, templates)
io.stdout:write(b)
assert(b=="- line 1\n- line 2\n- line 3\n")
print("ok")
