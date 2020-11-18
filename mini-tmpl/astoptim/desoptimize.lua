
--[[

Les string vide peuvent etre supprimé

Des strings successifs peuvent etre concatené en un seul
   {1, 0, "foo", "bar"}
=> {1, 0, "foobar"}

]]--

local C = require "mini-tmpl.common"
local const = assert(C.const)

local function desoptimize(ast)
	local a1=ast[1]

	local a2 = ast[2]
	if type(a2)~="table" then
		if not a2 or a2==0 then
			a2={}
		else
			a2={a2}
		end
	end

	if a1==const.VAR then
		assert(type(a2)=="table")
		local a21 = a2[1]		-- k+scope

		if type(a21)=="string" then	-- (string)k + nil(scope)
			a2[1]={{a21}, 0}
		else				-- k=a21[1] ; scope=a21[2]
			local a211 = a2[1]
			if type(a211)=="string" then
				a2[1] = {a211}	-- (string)k => (table)k
			end
			if a21[2]==nil then
				a21[2]=0
			end
		end
	end

	local a3 = ast[3]
	if not a3 or a3==0 then
		a3={}
	end
	return {a1, a2, a3}
end
return desoptimize
