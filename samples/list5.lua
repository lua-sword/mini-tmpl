local tmpl = require "mini-tmpl"
tmpl.render_mod.enabledynamic()
local prep = tmpl.prepare

local main = prep([[!{v>x}]])

local t_list = prep("- !{1}!\n")
t_list.usual = prep("- !{1},\n")
t_list.last = prep("- !{1}.\n")

local dynamicfield=require"mini-tmpl.common".dynamicfield
assert(dynamicfield=="dynamic")
local f = function(n,max)
	if n==max then return "last" end
	return "usual"
end
t_list[dynamicfield] = f

--table.insert(main[2],f)
--print(require"tprint"(main,{inline=false}))

local templates = {
	["x"] = t_list
}

local data = {
	 v={
		"line 1",
		"line 2",
		"line 3",
	}
}

--[[
local dbg = require "mini-tmpl.debug"
dbg.setname("main", main)
dbg.setname("t_list", t_list)
dbg.setname("t_list.usual", t_list.usual)
dbg.setname("t_list.last", t_list.last)
dbg.enabled = true
]]--

print(require"tprint"({main=main, data=data, templates=templates},{inline=false}))

local b = tmpl.render(main, data, templates, dynamicfield)
io.stdout:write(b)
assert(b=="- line 1,\n- line 2,\n- line 3.\n")
print("ok")
