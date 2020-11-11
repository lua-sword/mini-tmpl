
local M = {}
M._VERSION = "mini-tmpl.mkast 0.5.0"

local const = assert(require "mini-tmpl.common".const)

local unpack = table.unpack or unpack

M.getf		= function(fname)			return {const.GETF,	1, fname			} end
M.gett		= function(template_name)		return {const.GETT,	1, template_name		} end

M.template	= function(content)			return {const.TEMPLATE,	0, unpack(content or {})	} end

M.var		= function(varname, scope)		return {const.VAR,	2, varname, scope		} end
--M.varlocal	= function(varname, scope)		return {const.LVAR,	1, varname, 			} end
--M.varglobal	= function(varname, scope)		return {const.GVAR,	1, varname, 			} end
--M.varmeta	= function(varname, scope)		return {const.MVAR,	1, varname, 			} end

M.loop		= function(varname, template_name)	return {const.LOOP,	3, varname, template_name, false} end

M.include	= function(template_name)		return {const.INCLUDE,	1, template_name		} end
M.include2	= function(template_name)		return {const.TEMPLATE,	0, M.gett(template_name)	} end

M.static	= function(x) assert(type(x)=="string")	return x end

return M
