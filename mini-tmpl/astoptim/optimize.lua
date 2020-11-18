
--[[

Les string vide peuvent etre supprimé

Des strings successifs peuvent etre concatené en un seul
   {1, 0, "foo", "bar"}
=> {1, 0, "foobar"}

]]--

local C = require "mini-tmpl.common"
local const = assert(C.const)

local function optimize(ast)
	local a1=ast[1]

	local a2 = ast[2]
	if type(a2)=="table" then
		if #a2<=1 then
			a2=a2[1] or 0
		end
	end
	if a1==const.VAR then
		assert(type(a2)=="table")
		local a21 = a2[1]		-- k+scope
print("a21="..require"tprint"(a21))
		if type(a21)=="table" and #a21 <= 2 and (a21[2] or 0) == 0 then
			a21=a21[1]
			a2[1]=a21
		end
		if type(a21)=="table" and #a21<=2 and type(a21[1])=="string" and (a21[2] or 0)==0 then
			a2[1] = a21[1]
		end
	end

	local a3 = ast[3]
	if type(a3)=="table" then
		if #a3==0 or a3==0 then
			a3=nil
		else
			local new={}
			for i,v in ipairs(a3) do
				new[#new+1] = optimize(v)
			end
			a3=new
		end
	end
	return {a1, a2, a3}
end
return optimize
