
local M = {}

-- default marks
M.openmark = '!{'
M.closemark = '}'

local function prepare(txt_tmpl, openmark, closemark)
	if not openmark then openmark = M.openmark end
	if not closemark then closemark = M.closemark end
	local r = {}
	local addstatic = function(x) table.insert(r, x) end
	local addmark = function(x) table.insert(r, {x,tag="mark"}) end
	local trailing = string.gsub(txt_tmpl, "(.-)"..openmark.."([0-9a-z]+)"..closemark, function(a,b)
		if a and a~="" then
			addstatic(a)
		end
		if b then
			if b:find("^[0-9]+$") then -- is a base10 number
				local n = assert(tonumber(b, 10), "fail to convert base10 number")
				addmark(n)
			else	-- is a text key mark
				addmark(b)
			end
		end
		return ""
	end)
	if trailing and trailing~="" then
		addstatic(trailing)
	end
	r.tag="template"
	return r
end
M.prepare = prepare

local function render(ast, values)
	if type(ast)=="string" then
		return ast
	end
	if type(ast)=="table" and type(ast.tag)=="string" then
		local f = M.ast[ast.tag]
		if not f then
			error("no handler for ast type "..ast.tag)
		end
		return f(ast, values)
	end
	error("ast invalid type, must be a table(template|mark) or a string, got "..type(ast))
end
M.render=render

M.ast = {}
M.ast["template"] = function(ast, values)
	local r = {}
	for _i, a in ipairs(ast) do
		table.insert(r, render(a, values))
	end
	return table.concat(r,"")
end
M.ast["mark"] = function(ast, values)
	local k = assert(ast[1])
	local v2 = values[k]
	assert(v2, "no value found for "..tostring(k))
	for _n=1,10 do -- while v3 is a template (max 1000 recursions)
		v2 = render(v2, values)
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
return M
