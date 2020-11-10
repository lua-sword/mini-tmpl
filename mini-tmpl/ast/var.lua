-- varname -> string value
-- ast: {1<type>, 2<args(=2)>, 3<k>, 4<scope>, 5...}
return function(ast, parent, current)
	assert(type(ast[1])=="number")
	local astargs = assert(ast[2])
	assert(astargs==2)

	local values = assert(current.values or parent.values)
	assert(type(values)=="table", "tmpl.ast.var(): values must be a table")
	local k = assert(ast[3])
	local scope = assert(ast[4])
	local v2
	if scope and values[scope] then
		v2 = values[scope][k]
	else
		v2 = values[k]
	end

	if not v2 then v2="" end
	--assert(v2, "no value found for "..tostring(k))

-- FIXME cest quoi ce block de code ?!!
--[[
	local tag = 1
	for _n=1,10 do -- while v3 is a template (max 10 recursions)
		v2 = render(v2, parent, current)
		if type(v2)~="table" then
			break
		end
		if v2[tag]~="template" then
			error("resolved is still not a valid value")
		end
	end
]]--
	assert(type(v2)=="string", "v2 is not a string ?!")
	return v2
end
