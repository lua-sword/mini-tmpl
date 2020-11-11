
return function(ast, parent, current)
	assert(type(ast[1])=="number")
	local astargs = assert(ast[2])
	local r
	for i=3,astargs do
		local v = ast[i]
		local f = eval(v, parent, current)
		if type(f)=="function" then
			r = f(r) -- f(r, parent, current) ?
		else
			error("pipe with other than functions ?!")
		end
	end
	return r
end
