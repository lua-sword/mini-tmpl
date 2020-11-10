
local M = {}
M._VERSION = "mini-tmpl.ast 0.5.0"

local const = assert(require "mini-tmpl.common".const)

-- SAMPLE
-- ast: {<type>, <args(=2)>,"foo","bar", "value1","value2"}
--        1       2          3     4      5        6

local AST = {}
M.ast = AST
for i, name in ipairs(const) do
	AST[i] = require("mini-tmpl.ast."..(name:lower()))
end

M.enabledynamic = function() AST[const.loop]=require"mini-tmpl.ast.loopdynamic" end

return M
