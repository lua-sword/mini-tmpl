local tmpl = require "tmpl"
local prep = tmpl.prepare

tmpl.astfield     = "Type"
tmpl.scopefield   = "Scope"

local main = prep([[!{v>1}]])

local t_list = prep("- !{1}!\n")
t_list.usual = prep("- !{1},\n")
t_list.last = prep("- !{1}.\n")

local dynamicfield = "Dynamic"

t_list[dynamicfield] = function(n,max)
	if n==max then return "last" end
	return "usual"
end

local templates = {
	[1] = t_list
}

local data = {
	 v={
		"line 1",
		"line 2",
		"line 3",
	}
}

--[[
local dbg = require "tmpl.debug"
dbg.setname("main", main)
dbg.setname("t_list", t_list)
dbg.setname("t_list.usual", t_list.usual)
dbg.setname("t_list.last", t_list.last)
dbg.enabled = true
]]--

local b = tmpl.render(main, data, templates, dynamicfield)
io.stdout:write(b)
assert(b=="- line 1,\n- line 2,\n- line 3.\n")
print("ok")
