
-- Syntax: '!{' [<spaces>] [<var>] [<spaces>] [ '>' [<spaces>] <template> [<spaces> <ignored>] ]] '}'
-- pour avoir
--	!{>tmpl1}
--	!{var1}
--	!{var1>tmpl1}
--	!{ var1 > tmpl1 } avec des espaces qui seront ignorés
-- also valid:
--	!{}			=> substitute to empty string
--	!{  }			=> substitute to empty string
-- invalid :
--	!{foo>}
--	!{>}

local M = {}
M._VERSION = "mini.tmpl 0.1.0"

-- default marks
M.openmark = '!{' -- if you change them, thing to quote them for lua pattern
M.closemark = '}'
M.capturepattern = "[0-9a-z >_-]+"

local static = function(x) return x end
local mark = function(v) return {v, tag="mark"} end
local loop = function(v, t) return {v, t, tag="loop"} end

-- expose them
M.static = static
M.mark = mark
M.loop = loop

local function prepare(txt_tmpl)
	local r = {tag="template"}
	local add = function(item) table.insert(r, item) end
--	local static = function(x) return x end
--	local mark = function(v) return {v, tag="mark"} end
--	local loop = function(v, t) return {v, t, tag="loop"} end

	local trailing = string.gsub(txt_tmpl, "(.-)"..M.openmark.."("..M.capturepattern..")"..M.closemark, function(a,b_c)
		if a and a~="" then
			add(static(a))
		end
		local b,c
		if b_c:find(">", nil, true) then -- *>*
			b,c = b_c:gsub("[ \t]+", " "):match("^ *([^ ]+) *> *([^ ]+) *$")
			assert(c~="", "template name is empty")
			assert(b)
		else
			--b = b_c:gsub("[ \t]+", " "):match("^[ ]*([^ ]+)")
			b = b_c:match("^[ \t]*([^ \t]+)")
			c = nil
		end
		-- avoid !{} or !{<spaces>} cases
		if b and b~= "" then
			if b:find("^[0-9]+$") then -- is a base10 number
				b = assert(tonumber(b, 10), "fail to convert base10 number")
			end
			if c then -- add as "loop" ... ou bien mark avec 2 paramettres ?
				add(loop(b, c))
			else
				add(mark(b))
			end
		end
		return ""
	end)
	if trailing and trailing~="" then
		if trailing==txt_tmpl then error("Warning: the template seems not parsed at all") end
		add(static(trailing))
	end
	return r
end
M.prepare = prepare

local function render(ast, values, templates)
	if type(ast)=="string" then
		return ast
	end
	if type(ast)=="table" and type(ast.tag)=="string" then
		local f = M.ast[ast.tag]
		if not f then
			error("no handler for ast type "..ast.tag)
		end
		return f(ast, values, templates)
	end
print(require"tprint"(ast))
	error("ast invalid type, must be a table(template|mark) or a string, got "..type(ast).." type="..tostring(ast.tag))
end
M.render=render

M.ast = {}
M.ast["template"] = function(ast, values, templates)
	local r = {}
	for _i, a in ipairs(ast) do
		table.insert(r, render(a, values, templates))
	end
	return table.concat(r,"")
end
M.ast["mark"] = function(ast, values, templates)
	assert(ast[2]==nil)
	local k = assert(ast[1])
	local v2 = values[k]
	assert(v2, "no value found for "..tostring(k))
	for _n=1,10 do -- while v3 is a template (max 10 recursions)
		v2 = render(v2, values, templates)
		if type(v2)~="table" then
			break
		end
		if v2.tag~="template" then
			error("resolved is still not a valid value")
		end
	end
	assert(type(v2)=="string", "v2 is not a string ?!")
	return v2
end
M.ast["loop"] = function(ast, values, templates)
	--local tprint=require"tprint"
	--print(tprint({ast, values, templates}, {inline=false}))
	local k = assert(ast[1])
	local templatename = assert(ast[2])
	local list = assert(values[k])
	local template = templates[templatename]
	--print("k=", k, "templatename=", templatename, "list=", tprint(list), "template=", tprint(template))
	local r = {}
	for i,item in ipairs(list) do
		--print(i, item[1], item[2])
		--print( render(template, item, templates))
		table.insert(r, render(template, item, templates)) -- fallback value item => setmetatable(item, {__index=values})
	end
	return table.concat(r,"")
end
M.eolcontrol = function(...) return require"tmpl.eolcontrol"(...) end
return M
