-- ast: {1<type>, 2<astargs(=1)>, 3<templatename>, 4...}
return function(ast, parent, current)
	local intoparent = "templates"
	local astargs = assert(type(ast[1])=="number")
	assert(astargs==1)
	local k = assert(ast[3]) -- templatename
	local t = parent[intoparent]
	assert(t)
	local v = t[k]
	return v
end
