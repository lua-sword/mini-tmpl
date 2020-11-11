
local M = {}
M._VERSION = "mini-tmpl.ast 0.5.0"

local const = assert(require "mini-tmpl.common".const)

-- SAMPLE
-- ast: {<type>, <args(=2)>,"foo","bar", "value1","value2"}
--        1       2          3     4      5        6

local AST = {}
M.ast = AST
for i, name in pairs(const) do
	if type(i)=="number" then
--		print("AST", i, name)
		AST[i] = AST[i] or require("mini-tmpl.ast."..(name:lower()))
	end
end

M.enabledynamic = function() AST[const.LOOP]=require"mini-tmpl.ast.loopdynamic" end

return M
