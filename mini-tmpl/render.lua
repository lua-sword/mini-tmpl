
local M = {}
M._VERSION = "mini-tmpl.render 0.3.0"

local C = require "mini-tmpl.common"

local function internal_render(ast, values, templates, dynamicfield)
	assert(dynamicfield, "missing dynamicfield")

	if type(ast)=="string" then -- use native string instead of {tag="string", "foo"} aka `String{"foo"}
		return ast
	end
	local tag = C.astfield
	if type(ast)=="table" and type(ast[tag])=="string" then
		local f = M.ast[ast[tag]]
		if not f then
			error("no handler for ast type "..ast[tag])
		end
		return f(ast, values, templates, dynamicfield)
	end
	error("ast invalid type, must be a table(template|var|loop|include) or a string, got "..type(ast).." type="..tostring(ast[tag]))
end
local function pub_render(ast, values, templates, dynamicfield)
	if not dynamicfield then dynamicfield = C.dynamicfield end
	return internal_render(ast, values, templates, dynamicfield)
end
M.render=pub_render

M.ast = {}
M.ast["template"] = function(ast, values, templates, dynamicfield)
	local r = {}
	for _i, v in ipairs(ast) do
		if type(v)=="string" then -- use native string instead of `String{"foo"}
			table.insert(r, v)
		else
			table.insert(r, internal_render(v, values, templates, dynamicfield))
		end
	end
	return table.concat(r,"")
end

-- usefull to include static content (template without mark)
M.ast["include"] = function(ast, values, templates, dynamicfield)
	local templatename = ast[1]
	local template = templates[templatename]
	return internal_render(template, values, templates, dynamicfield)
end

-- varname -> string value
M.ast["var"] = function(ast, values, templates, dynamicfield)
	assert(ast[2]==nil)
	assert(type(values)=="table", "tmpl.ast.var(): values must be a table")
	local k = assert(ast[1])
	local scope = ast[C.scopefield]
	local v2
	if scope and values[scope] then
		v2 = values[scope][k]
	else
		v2 = values[k]
	end

	if not v2 then v2="" end
	--assert(v2, "no value found for "..tostring(k))

	local tag = C.astfield
	for _n=1,10 do -- while v3 is a template (max 10 recursions)
		v2 = internal_render(v2, values, templates, dynamicfield)
		if type(v2)~="table" then
			break
		end
		if v2[tag]~="template" then
			error("resolved is still not a valid value")
		end
	end
	assert(type(v2)=="string", "v2 is not a string ?!")
	return v2
end

-- varname -> list -> loop(list)
M.ast["loop"] = function(ast, values, templates, dynamicfield)
	local k = assert(ast[1])
	local templatename = assert(ast[2])
	assert( templatename and templatename~="" )
	if type(templatename)=="string" and templatename:find("^[0-9]+$") then -- is a base10 number
--		Dprint("convert templatename from string to number")
		templatename = assert(tonumber(templatename, 10), "fail to convert base10 number")
	end

	if k=="" then
		io.stderr:write("Warning k is an empty string")
	end
	local template = templates[templatename]
	assert(type(template)=="table")
	local list = values[k] or {""}
	local r = {}
	for i,item in ipairs(list) do
		local item2=item
		if type(item)=="string" then
			item2={item,i=tostring(i)}
		end
		local values2 = {["meta"]={i=tostring(i)}, ["local"]=item2, ["global"]=values, item}
		table.insert(r, internal_render(template, values2, templates, dynamicfield))
	end
	return table.concat(r,"")
end

-- varname -> list -> loop(list)
M.ast["loopDynamic"] = function(ast, values, templates, dynamicfield)
	assert(dynamicfield, "missing dynamicfield")
	--Dprint("DEBUG tmpl.ast.loop(): "..tprint({ast, values, templates}, {inline=false}))
	local k = assert(ast[1])
	local templatename = assert(ast[2])
	assert( templatename and templatename~="" )
	if type(templatename)=="string" and templatename:find("^[0-9]+$") then -- is a base10 number
--		Dprint("convert templatename from string to number")
		templatename = assert(tonumber(templatename, 10), "fail to convert base10 number")
	end

	if k=="" then
		io.stderr:write("Warning k is an empty string")
	end
	local template = templates[templatename]
	assert(type(template)=="table")
	local list = values[k] or {""}
--	if k=="*" then
--		io.stderr:write("Warning k is a star!")
--		return internal_render(template, values, templates, dynamicfield)
--	end
	local dynamic = nil
	local subtemplatesparent = nil
	if type(template[dynamicfield])=="function" then
		--Dprint("DEBUG: template[dynamicfield] FOUND!")
		dynamic = template[dynamicfield]
		subtemplatesparent = template
		assert(type(subtemplatesparent)=="table")
	end
	local r = {}
	for i,item in ipairs(list) do
		-- dispatch function + sub templates
		if dynamic then
			local searchinto, name = dynamic(i, #list)
			if name==nil and searchinto then -- compat: when only one argument is returned, consider that is name
				name,searchinto = searchinto,nil
			end
			assert(name, "dynamic function must return 2 arguments, subtemplate name is missing")
			local subtemplates = subtemplatesparent
			if searchinto then -- if searchinto==false|nil search into the parent
				assert(type(searchinto)=="string" or type(searchinto)=="number")
				--Dprint("searchinto=", searchinto)
				assert(type(subtemplatesparent[searchinto])=="table", "subtemplatesparent[searchinto] must be a table, found: "..type(subtemplatesparent[searchinto]))
				subtemplates = subtemplatesparent[searchinto]
			end
			assert(type(subtemplates)=="table")
			if subtemplates[name] then
				template = subtemplates[name]
			end
		else
			--Dprint("DEBUG: NO dynamic")
		end
		local item2=item
		if type(item)=="string" then
			--Dprint("convert item from", item)
			item2={item,i=tostring(i)}
			--Dprint("to", tprint(item))
		end
		local values2 = {["meta"]={i=tostring(i)}, ["local"]=item2, ["global"]=values,}

		table.insert(r, internal_render(template, values2, templates, dynamicfield)) -- fallback value item => setmetatable(item, {__index=values})
	end
	return table.concat(r,"")
end

-- function(templates, values, functions, config)
-- args = { templates, values, functions, {dynamicfield="DYN", main=1})
M.ast["Convert"] = function(ast, values, templates, dynamicfield) -- +functions
end

M.enabledynamic = function() M.ast.loop=M.ast.loopDynamic end

setmetatable(M, {__call=function(_, ...) return pub_render(...) end})

return M
