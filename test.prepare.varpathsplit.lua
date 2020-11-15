
do local plainsplit = require "mini-string-split-plain" end
local varpathsplit = require "mini-tmpl.prepare.varpathsplit"

local test = function(v)
	local r, v2 = varpathsplit(v)
	return require"tprint"(r), v2, v
end
local passert = print
passert(test    "foo.bar..buz")
passert(test   ".foo.bar..buz") --        "foo;bar;..;buz")
passert(test  "..foo.bar..buz") --     "..;foo;bar;..;buz")
passert(test "...foo.bar..buz") --   "ROOT;foo;bar;..;buz")
passert(test    "foo.bar.__.buz") --      "foo;bar;..;buz")



v = [[.foo."bar buz".x."y z".w]]
v = [[.foo."bar buz".x."y z".w]]
--v = [["bar buz".x."y z".w]]
local r = test(v)
print(r)
