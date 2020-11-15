-- usefull to include static content (template without mark)
-- ast: {1<type>, 2<astargs(=1)>, 3<templatename>, 4...}
return function(ast, ARGS, CONTENT, parent, current, meta)
	assert(#ARGS==1)

	local templatename = ARGS[1]
	local templates = assert(parent.templates)
	local template = templates[templatename]
	local render = assert(parent.render)
	return render(template, parent, current)
end
