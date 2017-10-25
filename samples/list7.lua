local tmpl = require "tmpl"
local prep = tmpl.prepare

tmpl.astfield     = "Type"
tmpl.scopefield   = "Scope"

local main = prep([[!{v>1}]])

local t_list = prep("- !{1}!\n")

local sub = {
	usual = prep("- !{1},\n"),
	last = prep("- !{1}.\n"),
}

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

--[=[
local dbg = require "tmpl.debug"
dbg.setname("main", main)
dbg.setname("t_list", t_list)
dbg.setname("t_list.usual", t_list.usual)
dbg.setname("t_list.last", t_list.last)
dbg.enabled = true
]=]--

local b = tmpl.render(main, data, templates, dynamicfield)
io.stdout:write(b)

--[=[
local main = prep [[ ... ]]
main:addtemplate(1, prep[[ ... ]])
main:setdynamic(dynamicfield)
local b = main:render(data)
io.stdout:write(b)
]=]--

--[=[
local b = tmpl(prep([[ ... ]])) -- tmpl(ast) -> instance
	:addtemplate(1, prep[[ ... ]])
	:setdynamic(dynamicfield)
	:render(data)
io.stdout:write(b)
]=]--

--[=[
local b = tmpl() -- tmpl() -> instance -> render
	:main(prep([[ ... ]])
	:addtemplate(1, prep[[ ... ]])
	:setdynamic(dynamicfield)
	:render(data)
io.stdout:write(b)
]=]--

--[=[
local b = tmpl(prep([[ ... ]])) -- tmpl(ast) -> instance
	:addtemplate(1, prep[[ ... ]])
	:setdynamic(dynamicfield)
	:render(data)
io.stdout:write(b)
]=]--
