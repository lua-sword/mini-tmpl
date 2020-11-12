-- usefull to include static content (template without mark)
-- ast: {1<type>, 2<astargs(=1)>, 3<templatename1>, [N<templatename2> ...], N+1...}
return function(ast, parent, current)
	assert(type(ast[1])=="number")
	local astargs = assert(ast[2])
	assert(astargs>=1)

	if astargs==1 then
		local templatename = assert(ast[3])
		local new = mk_gett(templatename)
	else
		error("include more than one template is not supported yet")

		local tmp = {}
		for i=3,3+astargs do local v = ast[i]
			local template = mk_gett(v)
			table.insert(tmp, template)
		end
		local new = mk_template(unpack(tmp))
	end
print("include2:", require"tprint"(new))
	return render(new, parent, current)
end
