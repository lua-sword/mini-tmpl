
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
	if type(ast)=="table" and ast.tag=="mark" then -- mark
		local k = assert(ast[1])
		local v2 = values[k]
		assert(v2, "no value found for "..tostring(k))
		local v3 = v2
		for _n=1,10 do -- while v3 is a template (max 1000 recursions)
			v3 = render(v3, values)
			if type(v3)~="table" then
				break
			end
			--if v3.tag=="template" then
			--	v3 = render(v3, values)
			--else
			if v3.tag~="template" then
				error("resolved is still not a valid value")
			end
		end
		assert(type(v3)=="string", "v3 is not a string ?!")
		return v3
	elseif type(ast)=="table" and ast.tag=="template" then
		local r = {}
		for _i, a in ipairs(ast) do
			table.insert(r, render(a, values))
		end
		return table.concat(r,"")
	end
	error("ast invalid type, must be a table(template|mark) or a string, got "..type(ast))
end
M.render=render
return M
