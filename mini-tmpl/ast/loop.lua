
-- varname -> list -> loop(list)
-- ast: {1<type>, 2<args(=2)>, 3<k>, 4<templatename>, 5<dynamicfield(false)> 6...}
return function(ast, parent, current)
	assert(type(ast[1])=="number")
	local astargs = assert(ast[2])
	assert(astargs==3) -- dynamicfield is not used
	local render = assert(parent.render)

	local k = assert(ast[3])
	assert( k and k~="" )

	local templatename = assert(ast[4])
	assert( templatename and templatename~="" )

	local templates = assert(parent.templates)
	local template = templates[templatename]
	if not template and type(templatename)=="string" and templatename:find("^[0-9]+$") then -- is a base10 number
		local templatename = tonumber(templatename, 10)
		template = templatename and templates[templatename]
	end
	assert(template, "ERROR: missing template '"..tostring(templatename).."'")
	assert(type(template)=="table", "ERROR: template is not a table")
	local values = assert(parent.values)
	local list = values[k] or {""}
	local r = {}
	for i,item in ipairs(list) do
		local item2=item
		if type(item)=="string" then
			item2={item,i=tostring(i)}
		end
		local values2 = {["meta"]={i=tostring(i)}, ["local"]=item2, ["global"]=values}
		local current = {values = values2}
		table.insert(r, render(template, parent, current))
	end
	return table.concat(r,"")
end
