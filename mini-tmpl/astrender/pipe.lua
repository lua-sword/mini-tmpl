
return function(ast, ARGS, CONTENT, parent, current, meta)
	assert(#ARGS==0)
	local eval = assert(parent.eval)
	local r
	for i,v in ipairs(CONTENT or {}) do
		local v = ast[i]
--print(i,v,require"tprint"(v))
		local f = eval(v, parent, current)
		if type(f)=="function" then
			r = f(r) -- f(r, parent, current) ?
		else
			error("pipe with other than functions ?!")
		end
	end
--print("pipe final:", require"tprint"(r))
	return r
end
