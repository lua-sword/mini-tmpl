local tmpl = require "tmpl"
local prep = tmpl.prepare

local main = prep([[!{v>1}]])

local t_list = prep("- !{1}!\n")
t_list.usual = prep("- !{1},\n")
t_list.last = prep("- !{1}.\n")

t_list.dynamic = function(n,max)
	if n==max then return "last" end
	return "usual"
end

--main.dynamic = t_list.dynamic

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
local b = tmpl.render(main, data, templates)
io.stdout:write(b)
