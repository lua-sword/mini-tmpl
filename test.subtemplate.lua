local tmpl = require "mini-tmpl"
local prep = tmpl.prepare

--[=[

local main = prep[[!{lx>tx}]]
main.dynamic = function(n, total)
	print(".dynamic:", n, total)
	return (n%2==1) and "foo" or "bar" end
main.sub = main.sub or {}
main.sub.foo = "a FOO!" -- prep([[a FOO!]], true) -- no mark, need to force
main.sub.bar = "a BAR!" -- prep([[a BAR!]], true) -- no mark, need to force


local tx = prep [[<!{1}>]]
tx.dynamic = main.dynamic
tx.sub = main.sub

print(tmpl.render(main, {lx={"aa", "bb"}}, {tx=tx}))
]=]--


local Prep = function(x)
	return prep( (x:gsub("[\t\n]","")) )
end

local peoples = prep[[*!{1}*, ]]
peoples.dynamic = function(n, total)
--print("DYN", n, total)
	local last=total
	if last-n == 1 then
--print("DYN", n, total, "returns", "sub/last_last")
		return "sub", "last_last"	-- => peoples.sub.last_last
	end
	if n == total then
--print("DYN", n, total, "returns", "nil/last")
		return nil, "last"		-- => peoples.last
		--return false, "last"		-- => peoples.last
	end
--print("DYN", n, total, "returns", "1")
	return 1				-- => peoples (the template itself, peoples[1])
	--return "ok"				-- => peoples.ok
end
peoples.sub={}
--peoples.sub.ok=prep [[!{1}, ]]
peoples.sub.last_last=prep [[!{1} and ]]
--peoples.sub.last=prep [[!{1}]]

--peoples.ok=prep [["!{1}", ]]
--peoples.last_last=prep [["!{1}" and ]]
peoples.last=prep [["!{1}"]]


local templates = {}
templates.peoples = peoples		-- for !{peoples>peoples}
templates[1] = peoples			-- for !{peoples>1} or !{peoples>}

-- hello( [<template>], <peoples> )
local function hello(t, peoples)
	if peoples==nil then
		peoples,t=t,nil
	end
	local main
	if t==nil then
		main = prep[[Hello !{1>peoples}!]]
	else
		main = prep(t)
	end
	return tmpl.render( main, {peoples}, templates)
end

print( hello(	[[Hellooo !{1>peoples}!]],	{ {"foo"} 			} ))
print( hello(				{ {"bar"}, {"foo"}		} ))
print( hello(				{ {"baz"}, {"bar"}, {"foo"}	} ))
templates.peoples=nil
print( hello(	[[Hi !{1>1}!]],			{ "buz", "baz", "bar", "foo"	} ))
print( hello(	[[Hi !{1>}!]],			{ "buz", "baz", "bar", "foo"	} ))
print( hello(   [[Hi !{>1}!]],                   { "buz", "baz", "bar", "foo"    } ))
print( hello(   [[Hi !{>}!]],                   { "buz", "baz", "bar", "foo"    } ))
templates[0]=templates[1]
templates[1]=nil
print( hello(   [[Hi !{>0}!]],                   { "buz", "baz", "bar", "foo"    } ))
-- !{ COIN >o_/ }
print("----")
--print( hello(	[[Hello11 !{1>1}!]], {{ "f00" }} ))

local dbg = tmpl.debug
dbg=nil
local debugname = dbg and dbg.setname or function(n, t) return t end
print(
	tmpl.render(
		debugname("main", prep[[_!{
					1	 	 	 	  
					 > 	 	 
					  x 	 	 	 
}_]]),
		{
			{"foo", "bar"},
		}, {
			x = debugname("x", prep[[!{1}, ]]),
		}
	)
)
