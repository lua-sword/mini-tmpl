
local M = {}
M._VERSION = "mini-tmpl.common 0.5.0"

local const = {"TEMPLATE","INCLUDE","LOOP","VAR","IF","PIPE", "EVAL"}
for i,name in ipairs(const) do
	const[name]=i
end
local const_internal = {"GETF", "GETT"}

local offset=100
for i, name in ipairs(const_internal) do
	const[i+offset] = name
	const[name] = i+offset
end

M.const = const

--M.astfield="tag"
--M.astfield=1

--M.scopefield="scope"
--M.scopefield=3

M.dynamicfield="dynamic"
--M.dynamicfield=4

return M
