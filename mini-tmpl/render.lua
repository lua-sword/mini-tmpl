
local M = {}
M._VERSION = "mini-tmpl.render 0.4.0"

local C = require "mini-tmpl.common"

local function internal_render(ast, parent, current)
	assert(parent.templates, "missing templates")
	assert(parent.values, "missing values")
	assert(parent.config, "missing config")
	assert(parent.config.dynamicfield, "missing config.dynamicfield")
	assert(parent.config.astfield, "missing config.astfield")
	assert(parent.config.main, "missing config.main")

	if type(ast)=="string" then -- use native string instead of an ast for String
		return ast
	end
	if type(ast)=="table" and type(ast[1])=="number" then
		local f = M.ast[ast[1]]
		if not f then
			error("no handler for ast type "..tostring(ast[1]))
		end
		return f(ast, parent, current)
	end
	error("invalid ast type, got "..type(ast))
end
local function pub_render(a, values, templates, dynamicfield) -- main, astfield
	if not dynamicfield then dynamicfield = C.dynamicfield end
	local config = {dynamicfield=dynamicfield, main=1, astfield=(C.astfield or "tag")}
	templates = templates or {}

	local ast
	if a==nil then
		ast = templates[config.main]
	elseif type(a) == "table" then
		ast = a
	else
		ast = assert(templates[a], "No such templates["..tostring(a).."]")
	end
	local parent = {values=values, templates=templates, config=config}
	return internal_render(ast, parent, {})
end
M.render=pub_render

local function pub_render2(templates, values, main, dynamicfield, astfield)
	assert(type(templates)=="table")
	assert(type(values)=="table")
	main = main or 1
	local config = {
		main = main,
		dynamicfield =(dynamicfield or C.dynamicfield or "dynamic"),
		astfield =(astfield or C.astfield or "tag"),
	}
	local parent = {templates=templates, values=values, config=config}
	local ast = assert(templates[main])
	return internal_render(ast, parent, {})
end
M.render2=pub_render2

M.ast = {}
M.ast[C.const.template] = function(ast, parent, current)
	assert(type(ast[1])=="number")
	local r = {}
	for i=2,#ast do
		local v=ast[i]
		if type(v)=="string" then -- use native string instead of `String{"foo"}
			table.insert(r, v)
		else
			table.insert(r, internal_render(v, parent, current))
		end
	end
	return table.concat(r,"")
end

-- usefull to include static content (template without mark)
M.ast[C.const.include] = function(ast, parent, current)
	assert(type(ast[1])=="number")
	local templatename = ast[2]
	local templates = assert(parent.templates)
	local template = templates[templatename]
	return internal_render(template, parent, current)
end

-- varname -> string value
M.ast[C.const.var] = function(ast, parent, current)
	assert(type(ast[1])=="number")
	local values = assert(current.values or parent.values)
	assert(type(values)=="table", "tmpl.ast.var(): values must be a table")
	local k = assert(ast[2])
	local scope = assert(ast[3])
	local v2
	if scope and values[scope] then
		v2 = values[scope][k]
	else
		v2 = values[k]
	end

	if not v2 then v2="" end
	--assert(v2, "no value found for "..tostring(k))

-- FIXME cest quoi ce block de code ?!!
--[[
	local tag = 1
	for _n=1,10 do -- while v3 is a template (max 10 recursions)
		v2 = internal_render(v2, parent, current)
		if type(v2)~="table" then
			break
		end
		if v2[tag]~="template" then
			error("resolved is still not a valid value")
		end
	end
]]--
	assert(type(v2)=="string", "v2 is not a string ?!")
	return v2
end

-- varname -> list -> loop(list)
M.ast[C.const.loop] = function(ast, parent, current)
	assert(type(ast[1])=="number")
	local k = assert(ast[2])
	local templatename = assert(ast[3])
	assert( templatename and templatename~="" )
	assert( k and k~="" )

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
		table.insert(r, internal_render(template, parent, current))
	end
	return table.concat(r,"")
end

-- list ->
-- actuellement on a 	=> !{.i} !{1}
-- i,v
-- pour i on a .i ?
-- _G ; _L? ;
--    {[0]=i, [1]=v}	=> !{0} !{1}
-- ou {[1]=i, [2]=v}		=> !{1} !{2}
-- ou {i=i,     v=v}	=> !{i} !{v}
-- ou {i=i,   [1]=v}   	=> !{i} !{1}
-- on pourrait passer 2 arguments a la fonction, global et current ?
-- par default current==global
-- mais dans une boucle, current est crafté ...
-- comment accèder a "i" ?
-- comment acceder au niveau parent ?
-- on boucle et on veut ../separateur ?
-- current = {[".."]=parent, ["_G"]=db, [0]=i_or_k, [1]=v,   }
-- db =      {[".."]=db,     ["_G"]=db, [0]=nil,    [1]=..., }

-- varname -> list -> loop(list)
local function loopDynamic(ast, parent, current)
	assert(type(ast[1])=="number")

	local k = assert(ast[2])
	assert( k and k~="" )

	local templatename = assert(ast[3])
	assert( templatename and templatename~="" )

	local dynamicfield = assert(
		ast[4] or parent.config.dynamicfield, "missing dynamicfield")

	local templates = assert(parent.templates)
	local template = templates[templatename] -- try with k as string else convert k to number

	if not template and type(templatename)=="string" and templatename:find("^[0-9]+$") then -- is a base10 number
--print("TRY to convert the template name from string to number")
		local templatename = tonumber(templatename, 10)
		template = templatename and templates[templatename]
	end
	assert(type(template)=="table")
	local values = assert(parent.values)
	local list = values[k] or {""}
--	if k=="*" then
--		io.stderr:write("Warning k is a star!")
--		return internal_render(template, parent, current)
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
parent.values = values2
		table.insert(r, internal_render(template, parent, current)) -- fallback value item => setmetatable(item, {__index=values})
	end
	return table.concat(r,"")
end

-- function(templates, values, functions, config)
-- args = { templates, values, functions, {dynamicfield="DYN", main=1})
--M.ast[C.const.Convert] = function(ast, parent) -- +functions
--end

M.enabledynamic = function() M.ast[C.const.loop]=loopDynamic end

setmetatable(M, {__call=function(_, ...) return pub_render(...) end})

return M
