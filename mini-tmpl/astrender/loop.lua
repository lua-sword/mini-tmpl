local walk3 = require "mini-table-walk3"

-- TODO:
-- {intemplate, {{var, "foo", "local"}}, {{templatename, "t1"}}

-- varname -> list -> loop(list)
-- ast: {1<type>, 2{ 1<k>, 2<templatename>, 3[<dynamicfield(nil)>]}, 3{...} }
return function(ast, ARGS, CONTENT, parent, current, meta)

	assert(#ARGS>=2 and #ARGS<=3) -- dynamicfield is not used
	local render = assert(parent.render)

-- var name to var value
	local k = assert(ARGS[1])
	if type(k)~="table" and k~="" then
		k = {k}
	end

	local rootvalues = assert(parent.rootvalues)

--	local scope = ARGS[2] or "local"
	local scope = "local"

	local v2
	if scope=="global" then
		v2 = walk3(parent.rootvalues, k)
	else
--print("current", require"tprint"(current), "k", require"tprint"(k))
		v2 = walk3(meta, k) or walk3(current, k)
	end
--print("v2", require"tprint"(v2))

	if not v2 then v2="" end
	--assert(type(v2)=="string", "v2 is not a string ?!")



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

	if type(v2) == "table" then

		local r = {}
		for i,item in ipairs(v2) do
			local meta = {i=tostring(i), ["."]=item}
			local current = item
			table.insert(r, render(template, parent, current, meta))
		end
		return table.concat(r,"")
	end
print(require"tprint"({template=template,v2=v2, meta=meta},{inline=false}))
	return render(template, parent, v2, meta)
end
