-- ast: {1<type>, 2<args(=0)>, 3...}
return function(ast, ARGS, CONTENT, parent, current)
	local render = assert(parent.render)
	local r = {}
	for i,v in ipairs(CONTENT) do
		if type(v)=="string" then -- use native string instead of `String{"foo"}
			table.insert(r, v)
		else
			table.insert(r, render(v, parent, current))
		end
	end
	return table.concat(r,"")
end
