
local M = {}
M._VERSION = "mini-tmpl.common 0.5.0"

local const = {"template","include","loop","var","ifvar"}
for i,v in ipairs(const) do
	const[v]=i
end
M.const = const

--M.astfield="tag"
--M.astfield=1

--M.scopefield="scope"
--M.scopefield=3

M.dynamicfield="dynamic"
--M.dynamicfield=4

return M
