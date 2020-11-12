
return function(ast, parent, current)
print("pipe begin:", require"tprint"(ast))

	assert(type(ast[1])=="number")
	local astargs = assert(ast[2])
	assert(astargs==0)
	local eval = assert(parent.eval)
	local r
	for i=3+astargs,#ast do
		local v = ast[i]
print(i,v,require"tprint"(v))
		local f = eval(v, parent, current)
		if type(f)=="function" then
			r = f(r) -- f(r, parent, current) ?
		else
			error("pipe with other than functions ?!")
		end
	end
print("pipe final:", require"tprint"(r))
	return r
end
