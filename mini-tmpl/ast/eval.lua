
-- get a template from his name and render it
-- ast: {1<type>, 2<astargs(=1)>, 3<template>, 4...}
return function(ast, parent, current)
	assert(type(ast[1])=="number")
	local astargs = assert(ast[2]) 	assert(type(astargs)=="number")
	assert(astargs==1)
	local a = assert(ast[3]) -- ast
	assert(a)
print("eval type", parent.const[ast[1]], " a="..require"tprint"(a))
	local v=parent.render(a, parent, current)
print("evaluated v="..require"tprint"(v))
	return v
end
