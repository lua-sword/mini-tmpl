
local M = {}

-- default marks
M.openmark = '!{'
M.closemark = '}'

local function prepare(txt_tmpl, openmark, closemark)
	if not openmark then openmark = M.openmark end
	if not closemark then closemark = M.closemark end
	local r = {}
	local addstatic = function(x) table.insert(r, x) end
	local addmark = function(x) table.insert(r, {x}) end
	string.gsub(txt_tmpl, "(.-)"..openmark.."([0-9a-z]+)"..closemark, function(a,b)
		--print("abc", a, openmark..b..closemark)
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
	r._type="template"
	return r
end
M.prepare = prepare

local function render(t_tmpl, values)
	assert(t_tmpl._type=="template")
	local r = {}
	for _i, v in ipairs(t_tmpl) do
		if type(v) == "table" then
			if v._type=="template" then
				local v2 = render(v, values)
				table.insert(r, v2)
			else
				local k = assert(v[1])
				local v2 = values[k]
				assert(v2, "no value found for "..tostring(k))
				if type(v2)=="table" then
					if v2._type=="template" then
						local v3 = render(v2, values)
						table.insert(r, v3)
					else
						error("resolved is still not a valid value")
					end
				else
					assert(type(v2)=="string", "v2 is not a string ?!")
					table.insert(r, v2)
				end
			end
		elseif type(v) == "string" then
			table.insert(r, v) -- a static string added
		end
	end
	return table.concat(r,"")
end
M.render=render
return M
