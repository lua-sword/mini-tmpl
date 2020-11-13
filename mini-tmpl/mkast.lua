
local M = {}
M._VERSION = "mini-tmpl.mkast 0.5.0"

local const = assert(require "mini-tmpl.common".const)

local unpack = table.unpack or unpack

--M.name	= function(name)			return {const.NAME,	{name}				} end

M.getf		= function(fname)			return {const.GETF,	{fname},			} end
M.gett		= function(template_name)		return {const.GETT,	{template_name},		} end

M.template	= function(t_args, t_content)		return {const.TEMPLATE,	t_args or 0, t_content		} end

M.var		= function(varname, scope)		return {const.VAR,	{varname, scope}		} end
--M.varlocal	= function(varname, scope)		return {const.LVAR,	{varname}, 			} end
--M.varglobal	= function(varname, scope)		return {const.GVAR,	{varname}, 			} end
--M.varmeta	= function(varname, scope)		return {const.MVAR,	{varname}, 			} end

M.loop		= function(varname, template_name)	return {const.LOOP,	{varname, template_name, false},} end

M.include	= function(template_name)		return {const.INCLUDE,	{template_name},		} end
M.include2	= function(template_name)		return M.template(0, {M.gett(template_name)})		  end

M.static	= function(x) assert(type(x)=="string")	return x end

M.pipe		= function(...)				return {const.PIPE, 0, {...}}			end

return M
