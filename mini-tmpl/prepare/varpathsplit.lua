
local plainsplit = require "mini-string-split-plain"
local function varpathsplit(v)
	local insert = table.insert
	local r={}
	local function splita(a)
		local r2 = plainsplit(a,".")
		for i,v in ipairs(r2) do
--			print("add v", v)
			insert(r, v)
		end
		--insert(r, r2)
	end
	local function specialshortcut(x)
		x = x:gsub("^%.%.%.","ROOT.",1)
		return (x:gsub("%.%.", '."..".'))
	end
	v = specialshortcut(v)
	local z = v:gsub('([^"]-)%.?"([^"]*)"%.?', function(a,b)
--		print("a,b", a, b)
		--if a and a~="" and b:sub(1,1)=="." then
		--	b = b:sub(2)
		--end
		splita(a)
		insert(r,b) 
		return ""
	end)
	if z then
		splita(z)
	end
	return r, v
end

return varpathsplit
