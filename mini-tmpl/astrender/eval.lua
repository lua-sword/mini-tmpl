
-- get a template from his name and render it
-- ast: {1<type>, 2<astargs(=0)>, i3<template>, 4...}
return function(ast, ARGS, CONTENT, parent, current)
	assert(#ARGS==1)
	local a = assert(ARGS[1]) -- ast
--FIXME: si ARGS[1] est un ast il devrait etre en content ?!
	assert(a)
print("eval type", parent.const[ast[1]], " a="..require"tprint"(a))
	local v=parent.render(a, parent, current)
print("evaluated v="..require"tprint"(v))
	return v
end
