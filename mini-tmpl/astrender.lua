
local M = {}
M._VERSION = "mini-tmpl.ast 0.6.0"
M._ASTSPEC = "2020-11-12"

local const = assert(require "mini-tmpl.common".const)

local modname = ...

local AST = {}
M.ast = AST
for i, name in pairs(const) do
	if type(i)=="number" then
--		print("AST", i, name)
		AST[i] = AST[i] or require(modname.."."..(name:lower())) -- pcall ?
	end
end

M.enabledynamic = function() AST[const.LOOP]=require"mini-tmpl.ast.loopdynamic" end

return M
