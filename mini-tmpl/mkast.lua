
local M = {}
M._VERSION = "mini-tmpl.mkast 0.6.0"

local const = assert(require "mini-tmpl.common".const)

M.template	= function(t_args, t_content)		return {const.TEMPLATE,	t_args or 0, 	t_content	} end
M.pipe		= function(t_args, t_content)		return {const.PIPE,	t_args or 0, 	t_content	} end
M.var		= function(varname, scope)		return {const.VAR,	{varname, scope}		} end
M.loop		= function(varname, template_name)	return {const.LOOP,	{varname, template_name}	} end
M.include	= function(template_name)		return {const.INCLUDE,	{template_name}			} end
M.static	= function(x) assert(type(x)=="string")	return x end

return M
