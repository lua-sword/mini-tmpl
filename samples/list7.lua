local tmpl = require "mini-tmpl"
tmpl.render_mod.enabledynamic()
local prep = tmpl.prepare

local dynamicfield = "Dynamic"

local main = prep([[!{v>t}]]) -- equals to !{1>list}

local t_list = prep("- !{1},\n")
t_list.last  = prep("- !{1}.\n")
t_list[dynamicfield] = function(n,max)
	if n==max then return "last" end
	return "1"
end

local templates = { t=t_list }
templates[1] = main

local data = {
	v={
		"line 1",
		"line 2",
		"line 3",
	}
}

local r = tmpl.render(templates, data, {dynamicfield=dynamicfield})
io.stdout:write(r)
assert(r=="- line 1,\n- line 2,\n- line 3.\n")
print("ok")
