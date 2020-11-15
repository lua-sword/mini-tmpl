
-- ast: {1<type>, 2{ 1<functionname>}, }
return function(ast, ARGS, CONTENT, parent, current, meta)
	local k = assert(ARGS[1])
	local functions = assert(parent.functions)
	return functions[k]
end
