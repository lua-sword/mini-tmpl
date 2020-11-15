
-- get a template from his name and render it
-- ast: {1<type>, 2{ 1<templatename>}, 3{...} }
return function(ast, ARGS, CONTENT, parent, current, meta)
	assert(#ARGS==1)
	local k = assert(ARGS[1]) -- templatename
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
