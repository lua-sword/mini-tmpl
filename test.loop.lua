local tmpl = require "tmpl"
local prep = tmpl.prepare

local tx = prep [[!{1},]]  
tx.dynamic = function(n, total) return "foo" end
tx.sub = tx.sub or {}
tx.sub.foo = prep([[FOO!]], true) -- no mark, need to force

print(tmpl.render(tx, {[1]="hello"}))
assert(tmpl.render(tx, {[1]="hello"})=="hello,")

------------------------------------------------

do
	-- inject the data 'foo' into the template 'FOO'
	local maintemplate = prep [[!{foo>FOO}!]]
	-- create one sub-template named 'FOO'
	local FOO = prep( [[v1=!{1};v2=!{2};e=!{eol};!{^eol}]].." " )
	-- all templates
	local subtemplates = {FOO = FOO}
	-- the data
	local data ={
		foo={
			{"aa","AA", eol="X", }, -- i==1
			{"bb","BB", eol="Y", }, -- i==2
			{"cc","CC", eol="Z", }, -- i==3
			eol="A",		-- can not be accessed TODO: !{@x} only for string key ?
		},
		eol="\n",
	}
	print( tmpl.render(maintemplate, data, subtemplates) )
end

local a = prep [[!{foo>FOO}!]]
local all = {FOO = prep([[i=!{.i};v=!{1};!{^eol}]].." ")}
print(tmpl.render(a, {
	foo={"aa", "bb", "cc"},
	eol="\n",
}, all))


