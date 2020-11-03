
local M = {}
M._VERSION = "mini.tmpl 0.3.0"

-- ######################################################################## --

-- default marks
M.openmark = '!{' -- if you change them, thing to quote them for lua pattern
M.closemark = '}'
--M.captureprefixpattern= "[%^%.]?"
--M.captureignoredspaces = " \t\r\n"
--M.captureletter = "0-9a-zA-Z_-"
M.special = ">|"
--M.capturepattern = "["..M.captureignoredspaces..M.special..M.captureletter.."]+"

M.astfield="tag"
--M.astfield= setmetatable({},{__tostring=function()return "ASTfield"end,__metatable=true})

M.scopefield="scope"
M.dynamicfield="dynamic"


local static	= function(x)				return x end
local var	= function(varname, scope)		return {varname,		[M.astfield]="var", [M.scopefield]=scope} end
local loop	= function(varname, template_name)	return {varname, template_name,	[M.astfield]="loop"} end
local include	= function(template_name)		return {template_name,		[M.astfield]="include"} end

local function trim(s)
	return s:match("^%s*(.*%S)" or "")
end

-- split content inside a mark : "^foo|bar>buz" -> {"^foo","|","bar",">","buz"}
local function splitmarkcontent(data)
	local insert = table.insert
	local result = {}
	local trailing = data:gsub("([^"..M.special.."]+)(["..M.special.."])", function(a,b)
		insert(result, trim(a))
		insert(result, b)
		return ""
	end)
	insert(result, trim(trailing))
	return result
end

local function prepare(txt_tmpl, force)
	assert(type(txt_tmpl)=="string", "invalid template type, must be a string")
	local tag = M.astfield
	local ast = {[tag]="template"}
	local add = function(item) table.insert(ast, item) end

	local pat = "(.-)"..M.openmark.."(.-)".. M.closemark
	local trailing = string.gsub(txt_tmpl, pat, function(pre,value)
		-- pre: the text before a !{...} mark
		-- value: the value inside the mark

		if pre and pre~="" then
			add(static(pre))
		end

		local items = splitmarkcontent(value)

		local function isTemplate(x)
			return x == ">"
		end
		local function isFunc(x)
			return x == "|"
		end

		local use_func, use_template = false,false
		local v,f,t -- var, function, template

		--[[
		local function shift() table.remove(items, 1) end
		local function get() return items[1] end
		while #items > 0 do
		]]--

		local pos = 1
		local function shift() pos=pos+1 end
		local function get() return items[pos] end
		while pos <= #items do

			if isTemplate(get()) then
				use_template = true;	shift()
				t = get(); 		shift()
			elseif isFunc(get()) then
				use_func = true;	shift()
				f = get();		shift()
			else
				if v then
					error("varname already exists!")
				end
				v = get();		shift()
			end
		end

		if (not v or v == "") and (use_func) then -- or use_template ? no, allow !{>footer} to include static content
			v="1" -- default value
		end
		if use_func and (not f or f=="")then
			f="1"
		end
		if use_template and (not t or t=="")then
			t="1"
		end

		local pv=v and v:sub(1,1)
		local scope="local"
		if pv and pv == "." then
			scope="meta"
			v=trim(v:sub(2)) -- ". varname" -> "varname"
		elseif pv and pv == "^" then
			scope="global"
			v=trim(v:sub(2)) -- "^ varname" -> "varname"
		end

		--print("scope", scope)
		--print("var",    v)
		--print("func",   f)
		--print("templ",  t)
		--print("use_func", use_func, "use_template", use_template)

		-- avoid !{} or !{<spaces>} cases
		if v and v~= "" then
			if v:find("^[0-9]+$") then -- is a base10 number
				v = assert(tonumber(v, 10), "fail to convert base10 number")
			end
			if t then
				add(loop(v, t))
			else
				add(var(v, scope))
			end
		elseif t then
			add(include(t))
		end
		return ""
	end)
	if trailing and trailing~="" then
		if not force and trailing==txt_tmpl then
			io.stderr:write("Warning: the template seems not parsed at all\n")
			io.stderr:write(txt_tmpl.."\n")
			--error("Warning: the template seems not parsed at all",2)
		end
		add(static(trailing))
	end
	return ast
end
M.prepare = prepare

-- ########################################################################### --

local function internal_render(ast, values, templates, dynamicfield)
	assert(dynamicfield, "missing dynamicfield")

	if type(ast)=="string" then -- use native string instead of {tag="string", "foo"} aka `String{"foo"}
		return ast
	end
	local tag = M.astfield
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
	if not dynamicfield then dynamicfield = M.dynamicfield end
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
	-- FIXME IMPROVEME !
	return templates[ast[1]][1]
end

-- varname -> string value
M.ast["var"] = function(ast, values, templates, dynamicfield)
	assert(ast[2]==nil)
	assert(type(values)=="table", "tmpl.ast.var(): values must be a table")
	local k = assert(ast[1])
	local scope = ast[M.scopefield]
	local v2
	if scope and values[scope] then
		v2 = values[scope][k]
	else
		v2 = values[k]
	end

	if not v2 then v2="" end
	--assert(v2, "no value found for "..tostring(k))

	local tag = M.astfield
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
	local list = values[k] or {""}
	local template = templates[templatename]
	assert(type(template)=="table")
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

-- expose them (internaly not affected if overwritten)
M.static = static
M.var = var
M.loop = loop
M.include = include

return M
--
-- Syntax : '!{'  [<spaces>] ( [special] [value] )* '}'
-- special: '|' or '>'
-- value  : everything except special
--
-- !{ varname }
-- !{ varname | funcname }
-- !{ varname > templatename }
-- !{ varname | funcname > templatename }
-- !{ varname | funcname1 | funcname2 > templatename }
--
-- !{ "var name"  | "func name" > "temp late name" } TODO: supporte quote to allow space in name ?

-- Syntax: '!{' [<spaces>] [<var>] [<spaces>] [ '>' [<spaces>] <template> [<spaces> <ignored>] ]] '}'
-- pour avoir
--	!{>tmpl1}
--	!{var1}
--	!{var1>tmpl1}
--	!{ var1 > tmpl1 } avec des espaces qui seront ignorés
--
--	!{  var1 }	equivalent au futur !{ local var1 }  tout est local par defaut
--	!{ .var1 }      equivalent au futur !{ meta  var1 }
--	!{ ^var1 }	equivalent au futur !{ global var1 }
-- also valid:
--	!{}			=> substitute to empty string
--	!{  }			=> substitute to empty string
-- implicite name :
--	!{foo>}	!{ foo > }      equals to !{foo>1}
--	!{>}	!{ > }          equals to !{1>1}
--	!{1>}	!{>1}		equals to !{1>1}
-- TODO:
--	!{a>b foo bar}		=> use extra "foo bar" parametter (like jinja ?)
--	!{ a b c > d e f }	=> capturer plusieurs "mots" autour du '>' pour supporter un ou des prefixes
--
--	!{ tab1.tab2.var1 }	=> walk into tables ?

-- Limitations:
--  can not access a value by a number key as string
--		   t["1"]	=> not supported
--	!{1}	=> t[1]		=> ok
--	!{one}	=> t["one"]	=> ok


