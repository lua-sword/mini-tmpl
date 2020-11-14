
local plainsplit = require "mini-string-split-plain"

local function varpathsplit(v)
	v = v:gsub("%.%.%.","___."):gsub("%.%.",".__.")
	local items = plainsplit(v, ".")
	if items[1]=="" then table.remove(items,1) end
	for i,v in ipairs(items) do
		v = v=="___" and "ROOT" or v
		v = v=="__" and ".." or v
		v = v=="_" and "." or v
		items[i] =v 
	end
	return items
end

local test = function(v)
	return table.concat(varpathsplit(v),";")
end
assert(test    "foo.bar..buz" ==        "foo;bar;..;buz")
assert(test   ".foo.bar..buz" ==        "foo;bar;..;buz")
assert(test  "..foo.bar..buz" ==     "..;foo;bar;..;buz")
assert(test "...foo.bar..buz" ==   "ROOT;foo;bar;..;buz")
assert(test    "foo.bar.__.buz" ==      "foo;bar;..;buz")
return varpathsplit
