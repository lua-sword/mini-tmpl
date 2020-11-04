
local dbg = {}
dbg.name_field = "_debug_name"
function dbg.setname(name, t)
	t[dbg.name_field] = name
	return t
end
function dbg.getname(ast)
	return ast[dbg.name_field] or "?"
end
dbg.enabled = nil
return dbg
