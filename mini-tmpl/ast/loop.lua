
-- varname -> list -> loop(list)
-- ast: {1<type>, 2{ 1<k>, 2<templatename>, 3[<dynamicfield(nil)>]}, 3{...} }
return function(ast, ARGS, CONTENT, parent, current)
	assert(#ARGS==3) -- dynamicfield is not used

	local k = assert(ARGS[1])
	assert( k and k~="" )

	local templatename = assert(ARGS[2])
	assert( templatename and templatename~="" )

	local templates = assert(parent.templates)
	local template = templates[templatename]
	if not template and type(templatename)=="string" and templatename:find("^[0-9]+$") then -- is a base10 number
		local templatename = tonumber(templatename, 10)
		template = templatename and templates[templatename]
	end
	assert(template, "ERROR: missing template '"..tostring(templatename).."'")
	assert(type(template)=="table", "ERROR: template is not a table")
	local render = assert(parent.render)
	local rootvalues = assert(parent.rootvalues)
	local list = rootvalues[k] or {""}
	local r = {}
	for i,item in ipairs(list) do
		local item2=item
		if type(item)=="string" then
			item2={item,i=tostring(i)}
		end
		local values2 = {["meta"]={i=tostring(i)}, ["local"]=item2, ["global"]=rootvalues}
		local current = {values = values2}
		table.insert(r, render(template, parent, current))
	end
	return table.concat(r,"")
end
