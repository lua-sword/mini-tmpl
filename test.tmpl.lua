
local tmpl = require "tmpl"

local txt = {}
txt.foo = [[!{n}I am !{1} Hello !{2}!{n}]]
txt.bar = [[!{z} !{w}]]

do
	local t = tmpl.prepare(txt.foo)
	local t2 = tmpl.prepare(txt.bar)

	local v2 = tmpl.render(t2, {
		z="Z",
		w="WORLD",
	})
	local R = tmpl.render(t, {
		"ME",
		v2,
		["n"]="'",
	})
	print(R)
end

do
	local t = tmpl.prepare(txt.foo)
	local t2 = tmpl.prepare(txt.bar)

	local R = tmpl.render(t, {
		"ME",
		t2,
		["n"]="'",
		z="Z",
		w="WORLD",
	})
	print(R)
end
