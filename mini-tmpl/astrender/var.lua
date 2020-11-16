
local walk3 = require "mini-table-walk3"

-- FIXME cest quoi ce block de code ?!!
--[[
local function wtfcode(v2, parent, current)
	local render = assert(parent.render)
	local const = assert(parent.const)
	local tag = 1
	for _n=1,10 do -- while v3 is a template (max 10 recursions)
		v2 = render(v2, parent, current)
		if type(v2)~="table" then
			break
		end
		if v2[tag]~=const.TEMPLATE then
			error("resolved is still not a valid value")
		end
	end
	return v2
end
]]--

-- {VAR, {
--		0|k|t_k,
--		0|scope
--		0|TNAME,
--		[dynamicfield],
--	},
-- }

-- scopes={1"meta", 2"local", 3"global"}

-- IMPORTANT: dynamicfield n est plus utilisable pour l instant ! le 3eme argument est le nom du template

local scopes = {"meta","local","global"}
for i,v in ipairs(scopes) do
	scopes[v]=i
end

--[[
	ARGS
0	= 0										, "t1" -- include ??
1	= local_path_string		 , templ_name		"foo"			, "t1"
2	= { path_string, 	scope	}, templ_name		"foo", "global"		, "t1"
3	= { local_path_table		}, templ_name		{"foo", "bar"}		, "t1"
4	= { path_table, 	scope	}, templ_name		{"foo", "bar"}, "global", "t1"
INVALID CASE:
	= path_table, ...
]]--

-- varname -> list -> loop(list)
-- ast: {1<type>, 2{ 1{1<k>,2[<scope>]}, 2<templatename>, 3[<dynamicfield(nil)>]}, 3{...} }
return function(ast, ARGS, CONTENT, parent, current, meta)
--print("VAR:", require"tprint"(ast,{inline=false}))

	assert(#ARGS>=1 and #ARGS<=2) -- dynamicfield is not used

	-- var path and scope ---------------------------------------
	local k = assert(ARGS[1])

	if k==0 then
		error("no varpath, is it include ??")
	end

	local scope


	if type(k)=="table" then -- { path=<string|table>, [scope] }
		assert(#k<=2)
		scope = k[2] -- can be nil
		k = k[1]	-- k[1] can be string or path_table
	else
		assert(type(k)=="string")
		scope=nil	-- local scope
	end
	if type(k)=="string" then
		k = {k}		-- string key converted to a path_table
	end
	assert(type(k)=="table")
	if not scope or scope==0 then scope="local" end
	if type(scope)=="number" then scope=scopes[scope] or scope end
	assert(scopes[scope], "invalid scope value: "..tostring(scope))
	-------------------------------------------------------------

	-- get var-value from var-path ------------------------------
	local v2
	if scope=="global" then
		v2 = walk3(parent.rootvalues, k)
	else
		v2 = walk3(meta, k) or walk3(current, k)
	end
	if not v2 then v2="" end
	--assert(type(v2)=="string", "v2 is not a string ?!")
	-------------------------------------------------------------

	-- get template from template-name -------------------------- templatename, 
	local templatename = assert(ARGS[2])
	if templatename==0 then -- simple VAR, no template
		assert(type(v2)=="string", "v2 is not a string ?!")
		return v2
	end

	-- get template from template-name -------------------------- templatename, parent.templates 
	local function get_template(templatename, templates)
		assert( templatename and templatename~="" )
		local template = templates[templatename]
		if not template and type(templatename)=="string" and templatename:find("^[0-9]+$") then -- is a base10 number
			local templatename = tonumber(templatename, 10)
			template = templatename and templates[templatename]
		end
		assert(template, "ERROR: missing template '"..tostring(templatename).."'")
		assert(type(template)=="table", "ERROR: template is not a table")
		return template
	end
	local template = get_template(templatename, assert(parent.templates))

	local render = assert(parent.render)
	if type(v2) == "table" and #v2>0 then
--print("v2 is a table", require"tprint"(v2))
		local r = {}
		for i,item in ipairs(v2) do
			local newcurrent = item
			local newmeta = {i=tostring(i)}
			newmeta["."] = newcurrent
			newmeta[".."] = current
			table.insert(r, render(template, parent, newcurrent, newmeta))
		end
--print("VAR[OUT]:", require"tprint"(r,{inline=false}))
		return table.concat(r,"")
	end
--print("VAR[OUT]:", require"tprint"({template=template,v2=v2, meta=meta},{inline=false}))
	return render(template, parent, v2, meta)
end

--[===[

-- varname -> string value
-- ast: {1<type>, 2<args(=1)>, 3<k>, 4<scope>, 5...}
return function(ast, ARGS, CONTENT, parent, current, meta)
	assert(#ARGS>=1 and #ARGS<=2)
	local k = assert(ARGS[1])
	if type(k) ~="table" then k={k} end
	local scope = ARGS[2] or "local"

	local v2
	if scope=="global" then
		v2 = walk3(parent.rootvalues, k)
	else
--print("current", require"tprint"(current))
		v2 = walk3(meta, k) or walk3(current, k)
	end
	if not v2 then v2="" end

	--local v2 = wtfcode(v2, parent, current) -- FIXME cest quoi ce truc
	assert(type(v2)=="string", "v2 is not a string ?!")
	return v2
end

]===]--
