-- ast: {1<type>, 2<args(=0)>, 3...}
return function(ast, parent, current)
	assert(type(ast[1])=="number")
	local astargs = assert(ast[2])
	assert(astargs==0)
	local render = assert(parent.render)
	local r = {}
	for i=3+astargs,#ast do
		local v=ast[i]
		if type(v)=="string" then -- use native string instead of `String{"foo"}
			table.insert(r, v)
		else
			table.insert(r, render(v, parent, current))
		end
	end
	return table.concat(r,"")
end
