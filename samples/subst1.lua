local tmpl = require "mini-tmpl"

local template = tmpl.prepare "Hello !{1}."
local data = {"John"}
x = tmpl.render(template, data) -- 

-- similar to
y = string.format("Hello %s.", "John")

local function tmpl_format(t, ...)
	local fmt = tmpl.prepare(t)
	local data = {...}
	return tmpl.render(template, data)
end
z = tmpl_format("Hello !{1}.", "John")

assert(x==y)
assert(x==z)
