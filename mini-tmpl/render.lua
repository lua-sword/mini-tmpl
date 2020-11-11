
local M = {}
M._VERSION = "mini-tmpl.render 0.5.0"

local C = require "mini-tmpl.common"
assert(C.const)
local A = require "mini-tmpl.ast"
local AST = assert(A.ast)

local function internal_render(ast, parent, current)
	if type(ast)=="string" then -- use native string instead of an ast for String
		return ast
	end

	assert(parent.templates, "missing templates")
	assert(parent.rootvalues, "missing rootvalues")
	assert(parent.config, "missing config")
	assert(parent.config.dynamicfield, "missing config.dynamicfield")
	assert(parent.config.main, "missing config.main")
	assert(parent.render, "missing render")
	assert(parent.eval, "missing eval")
	assert(parent.const, "missing const")
	--assert(type(current)=="table", "current must be a table")

	if type(ast)=="table" and type(ast[1])=="number" then
print("render type", C.const[ast[1]], #ast, require"tprint"(ast))
		local f = AST[ast[1]]
		if not f then
			error("no handler for ast type "..tostring(ast[1]))
		end
		return f(ast, parent, current)
	end
	error("invalid ast type, got "..type(ast))
end

-- eval is like render but for internal use
local function eval(ast, parent, current)
	assert(ast[1]>=100)
	return internal_render(ast, parrent, current)
end

local function pub_render(templates, rootvalues, functions, conf) -- main, dynamicfield
	assert(type(templates)=="table")
	assert(type(rootvalues)=="table")
	functions = functions or {}
	conf = conf or {}
	assert(type(functions)=="table")
	assert(type(conf)=="table")
	local config = {
		main = conf.main or 1,
		dynamicfield = conf.dynamicfield or C.dynamicfield,
	}
	local parent = {
		templates=templates,
		rootvalues=rootvalues,
		functions=functions,
		config=config,
		render=internal_render,
		eval=eval,
		const=C.const
	}
	local ast = assert(templates[config.main])
	return internal_render(ast, parent, {})
end
M.render=pub_render

setmetatable(M, {__call=function(_, ...) return pub_render(...) end})

return M
