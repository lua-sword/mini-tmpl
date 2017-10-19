
local tprint=require"tprint"
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

local M = {}
M._VERSION = "mini.tmpl 0.1.0"

-- ######################################################################## --

-- try to load the debug module
local dbg = pcall(require, "tmpl.debug") and require "tmpl.debug"

-- default marks
M.openmark = '!{' -- if you change them, thing to quote them for lua pattern
M.closemark = '}'
M.captureprefixpattern= "[%^%.]?"
M.capturepattern = "[0-9a-zA-Z \t\r\n>_-]+" -- TODO: add tab ? add CR/LF ?
M.astfield="tag"
M.scopefield="scope"

local static = function(x) return x end
local var = function(varname, scope) return {varname, [M.astfield]="var", [M.scopefield]=scope} end
local loop = function(varname, template_name) return {varname, template_name, [M.astfield]="loop"} end

local function prepare(txt_tmpl, force)
	assert(type(txt_tmpl)=="string", "invalid template type, must be a string")
	local tag = M.astfield
	local ast = {[tag]="template"}
	local add = function(item) table.insert(ast, item) end
	--local static, var, loop = static, var, loop

	local trailing = string.gsub(txt_tmpl, "(.-)"..M.openmark.."("..M.captureprefixpattern..")("..M.capturepattern..")"..M.closemark, function(a,pv,v_t_x)
		-- a: the textt before a !{} mark
		-- pv: the first otionnal special char ('.' or '^')
		-- v: the variable name
		-- gt: the '>' separator
		-- t: the template name
		-- x: the xtra parametters
		if a and a~="" then
			add(static(a))
		end
		local scope="local"
		if pv == "." then scope="meta"
		elseif pv == "^" then scope="global"
		end
		v_t_x = v_t_x:gsub("[\r\n]+",""):gsub("[ \t]+", " ")	-- replace multiples spaces to only one one space
		local v,gt,t,x
		if v_t_x:find(">", nil, true) then -- !{*>*}
			v,gt,t,x = v_t_x:match("^ *([^ >]*) *(>) *([^ ]*) *(.*)$")
			--assert(t~="", "template name is empty")
			assert(gt==">")
			assert(v)
			assert(t)
			-- support of !{ [varname|1] > [templatename|1] } 
			if v=="" then -- when !{>templ} becomes equals to !{1>templ}
				v=1
			end
			if t=="" then -- when !{var>}  becomes equals to !{var>1}
				t=1
			end
			assert(x==nil or x=="", "xtra parameter are not implemented yet!")
		else
			v = v_t_x:match("^ *([^ ]+)")
		end
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
		end
		return ""
	end)
	if trailing and trailing~="" then
		if not force and trailing==txt_tmpl then error("Warning: the template seems not parsed at all",2) end
		add(static(trailing))
	end
	return ast
end
M.prepare = prepare

-- ########################################################################### --

local function render(ast, values, templates)
	if type(ast)=="string" then -- use native string instead of {tag="string", "foo"} aka `String{"foo"}
		return ast
	end
--print("DEBUG render:")
--print("  ast="..tprint(ast), type(ast))
--print("  values="..tprint(values), type(values))
--print("  templates="..tprint(templates), type(templates))

	local tag = M.astfield
	if type(ast)=="table" and type(ast[tag])=="string" then
		local f = M.ast[ast[tag]]
		if not f then
			error("no handler for ast type "..ast[tag])
		end
--print("render(): ["..ast[tag].."] f(ast, values, templates) :"..tprint({ast=ast, values=values, templates=templates,}, {inline=false}))
		return f(ast, values, templates)
	end
--print("DEBUG:", require"tprint"(ast))
	error("ast invalid type, must be a table(template|var|loop) or a string, got "..type(ast).." type="..tostring(ast[tag]))
end
M.render=render

M.ast = {}
M.ast["template"] = function(ast, values, templates)
	print("DEBUG tmpl.ast.template():", dbg and dbg.getname(ast) or "")
	local r = {}
	for _i, v in ipairs(ast) do
		if type(v)=="string" then -- use native string instead of `String{"foo"}
			table.insert(r, v)
		else
			table.insert(r, render(v, values, templates))
		end
	end
	return table.concat(r,"")
end

-- varname -> string value
M.ast["var"] = function(ast, values, templates)
	print("DEBUG tmpl.ast.var():")
	--print("  ast="..tprint(ast), type(ast))
	--print("  values="..tprint(values), type(values))
	--print("  templates="..tprint(templates), type(templates))
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

	local tag = M.astfield
	assert(v2, "no value found for "..tostring(k))
	for _n=1,10 do -- while v3 is a template (max 10 recursions)
		v2 = render(v2, values, templates)
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
M.ast["loop"] = function(ast, values, templates)
	print("tmpl.ast.loop(): "..tprint({ast, values, templates}, {inline=true}))
	local k = assert(ast[1])
	local templatename = assert(ast[2])
	local list = assert(values[k])
	local template = templates[templatename]
	assert(type(template)=="table")
	local dynamic = nil
	local subtemplatesparent = nil
--	print("type(template.dynamic)", type(template.dynamic), "type(template.sub)", type(template.sub))
	if type(template.dynamic)=="function" then
--		print("DEBUG: template.dynamic FOUND!")
		dynamic = template.dynamic
		subtemplatesparent = template
	end
	--print("k=", k, "templatename=", templatename, "list=", tprint(list), "template=", tprint(template))
	local r = {}
	for i,item in ipairs(list) do
		--print( render(template, item, templates))
		-- TODO: dispatch function + sub templates

		if dynamic then
			local searchinto, name = dynamic(i, #list)
			if name==nil and searchinto then -- compat: when only one argument is returned, consider that is name
				name,searchinto = searchinto,"sub"
			end
			assert(name, "dynamic function must return 2 arguments, subtemplate name is missing")
			local subtemplates = subtemplatesparent
			if searchinto then -- if searchinto==false|nil search into the parent
				subtemplates = subtemplatesparent[searchinto]
			end
			if subtemplates[name] then
				template = subtemplates[name]
			end
--		else
--			print("DEBUG: NO dynamic")
		end
		local item2=item
		if type(item)=="string" then
			--print("convert item from", item)
			item2={item,i=tostring(i)}
			--print("to", tprint(item))
		end
		local values2 = {["meta"]={i=tostring(i)}, ["local"]=item2, ["global"]=values,}

		table.insert(r, render(template, values2, templates)) -- fallback value item => setmetatable(item, {__index=values})
	end
	return table.concat(r,"")
end
M.eolcontrol = function(...) return require"tmpl.eolcontrol"(...) end

M.debug = dbg

-- expose them (internaly not affected if overwritten)
M.static = static
M.var = var
M.loop = loop


return M
