-- usefull to include static content (template without mark)
-- ast: {1<type>, 2<astargs(=1)>, 3<templatename>, 4...}
return function(ast, parent, current)
	assert(type(ast[1])=="number")
	local astargs = assert(ast[2])
	assert(astargs==1)

	local templatename = ast[3]
	local templates = assert(parent.templates)
	local template = templates[templatename]
	local render = assert(parent.render)
	return render(template, parent, current)
end
