local tmpl = require "tmpl"
local prep = tmpl.prepare

local tx = prep [[!{1},]]  
tx.dynamic = function(n, total) return "foo" end
tx.sub = tx.sub or {}
tx.sub.foo = prep([[FOO!]], true) -- no mark, need to force

print(tmpl.render(tx, {[1]="hello"}))
assert(tmpl.render(tx, {[1]="hello"})=="hello,")

------------------------------------------------

local a = prep [[!{foo>FOO}!]]
local all = {FOO = prep([[v1=!{1};v2=!{2};!{^eol}]].." ")}
print(tmpl.render(a, {
	foo={
		{"aa","AA"}, -- i==1
		{"bb","BB"}, -- i==2
		{"cc","CC"}, -- i==3
	},
	eol="\n",
}, all))

local a = prep [[!{foo>FOO}!]]
local all = {FOO = prep([[i=!{.i};v=!{1};!{^eol}]].." ")}
print(tmpl.render(a, {
	foo={"aa", "bb", "cc"},
	eol="\n",
}, all))


