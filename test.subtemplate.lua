local tmpl = require "tmpl"
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

local peoples = prep[[!{1}, ]]
peoples.dynamic = function(n, total)
	local last=total
	if last-n == 1 then
		return "last_last"
	end
	if n == total then
		return "last"
	end
	return "ok"
end
peoples.sub={}
peoples.sub.ok=prep [[!{1}, ]]
peoples.sub.last_last=prep [[!{1} and ]]
peoples.sub.last=prep [[!{1}]]

local templates = {}
templates.peoples = peoples
--templates[1] = templates.peoples -- prep[[!{peoples>peoples}]]
templates[""] = templates.peoples


local function hello(peoples, t)
	local main = prep[[Hello !{1>peoples}!]]
	if t then
		main = prep(t)
	end
	return tmpl.render( main, {peoples}, templates)
end

print(hello({ {"foo"} }, [[Hellooo !{1>}!]]))
print(hello{ {"foo"}, {"baz"} })
print(hello{ {"foo"}, {"bar"}, {"buz"} })
print(hello{ "foo", "bar", "buz", "bip" })


