
local walk3 = require "mini-table-walk3"

-- FIXME cest quoi ce block de code ?!!
--[[
local function wtfcode(v2, parent, current)
	local render = assert(parent.render)
	local const = assert(parent.const)
	local tag = 1
	for _n=1,10 do -- while v3 is a template (max 10 recursions)
		v2 = render(v2, parent, current)
		if type(v2)~="table" then
			break
		end
		if v2[tag]~=const.TEMPLATE then
			error("resolved is still not a valid value")
		end
	end
	return v2
end
]]--

-- varname -> string value
-- ast: {1<type>, 2<args(=1)>, 3<k>, 4<scope>, 5...}
return function(ast, ARGS, CONTENT, parent, current)
	assert(#ARGS>=1 and #ARGS<=2)
	local k = assert(ARGS[1])
	if type(k) ~="table" then k={k} end
	local scope = ARGS[2] or "local"

	local t, v2
	if scope=="meta" then
		t = assert(current.values)["meta"]
		assert(type(t)=="table", "metavalues must be a table")
		v2 = t[k]
	else
		if scope=="local" and assert(current, "current must be a table").values then
			t = current.values["local"]
			assert(type(t)=="table", "localvalues must be a table")
			v2 = walk3(t, k)
		end
		if v2==nil or scope=="global" then
			t = assert(parent.rootvalues)
			assert(type(t)=="table", "rootvalues must be a table")
			v2 = t[k]
		end
	end
	if not v2 then v2="" end

	--local v2 = wtfcode(v2, parent, current) -- FIXME cest quoi ce truc
	assert(type(v2)=="string", "v2 is not a string ?!")
	return v2
end
