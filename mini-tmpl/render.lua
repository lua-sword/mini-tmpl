
local M = {}
M._VERSION = "mini-tmpl.render 0.5.0"

local C = require "mini-tmpl.common"
local AST = require "mini-tmpl.ast".ast

local function internal_render(ast, parent, current)
	assert(parent.templates, "missing templates")
	assert(parent.values, "missing values")
	assert(parent.config, "missing config")
	assert(parent.config.dynamicfield, "missing config.dynamicfield")
	assert(parent.config.main, "missing config.main")
	assert(parent.render, "missing render")
	assert(type(current)=="table", "current must be a table")

	if type(ast)=="string" then -- use native string instead of an ast for String
		return ast
	end
	if type(ast)=="table" and type(ast[1])=="number" then
		local f = AST[ast[1]]
		if not f then
			error("no handler for ast type "..tostring(ast[1]))
		end
		return f(ast, parent, current)
	end
	error("invalid ast type, got "..type(ast))
end
local function pub_render(templates, values, conf) -- main, dynamicfield
	assert(type(templates)=="table")
	assert(type(values)=="table")
	conf = conf or {}
	assert(type(conf)=="table")
	local config = {
		main = conf.main or 1,
		dynamicfield = conf.dynamicfield or C.dynamicfield,
	}
	local parent = {templates=templates, values=values, config=config, render=internal_render}
	
	local ast = assert(templates[config.main])
	return internal_render(ast, parent, {})
end
M.render=pub_render

setmetatable(M, {__call=function(_, ...) return pub_render(...) end})

return M
