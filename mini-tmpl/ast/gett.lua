
-- get a template from his name and render it
-- ast: {1<type>, 2<astargs(=1)>, 3<templatename>, 4...}
return function(ast, parent, current)
	assert(type(ast[1])=="number")
	local astargs = assert(ast[2]) 	assert(type(astargs)=="number")
	assert(astargs==1)
	local k = assert(ast[3]) -- templatename
	local intoparent = "templates"
--print(require"tprint"(ast))
	local t = parent[intoparent]
	assert(t)
	local v = t[k]
--print("GOT v="..require"tprint"(v))
	v=parent.render(v, parent, current)
--print("GOT v="..require"tprint"(v))
	return v
end
