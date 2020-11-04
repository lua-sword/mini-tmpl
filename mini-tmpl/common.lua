
local M = {}
M._VERSION = "mini-tmpl.common 0.3.0"

M.astfield="tag"
--M.astfield= setmetatable({},{__tostring=function()return "ASTfield"end,__metatable=true})

M.scopefield="scope"
M.dynamicfield="dynamic"

return M
