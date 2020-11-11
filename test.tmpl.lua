
local tmpl = require "mini-tmpl"
local eolcontrol = require "mini-tmpl.eolcontrol"
assert(eolcontrol(([[
foo\n
bar
buz\n
\n
]]):gsub("\\n","!n"))=="foo\nbarbuz\n\n")

local txt = {}
txt.foo = (
[[!{q}
!{   }I am !{1}
!{             } Hello !{2}
!{                        }!{q}]]
):gsub("\n","")
txt.bar = [[!{z} !{w}]]

do
	local t = tmpl.prepare(txt.foo)
	local t2 = tmpl.prepare(txt.bar)
	local v2 = tmpl.render({t2}, {
		z="Z",
		w="WORLD",
	})
	local R = tmpl.render({t}, {
		"ME",
		v2,
		["q"]="'",
	})
	assert(R==[['I am ME Hello Z WORLD']])
end

do
--[[ -- test disabled : template into data is not allowed !
	local t = tmpl.prepare(txt.foo)
	local t2 = tmpl.prepare(txt.bar)
	local R = tmpl.render({t}, {
		"ME",
		t2,
		["q"]="'",
		z="Z",
		w="WORLD",
	})
	assert(R==[['I am ME Hello Z WORLD']])
]]--
end
print("ok")
