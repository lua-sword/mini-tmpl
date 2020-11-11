
-- ast: {1<type>, 2<astargs(=1)>, 3<functionname>}
return function(ast, parent, current)
	assert(type(ast[1])=="number")
	local k = assert(ast[3])
	local functions = assert(parent.functions)
	return functions[k]
end
