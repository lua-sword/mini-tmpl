local tmpl = require "mini-tmpl"

local t = {tmpl.prepare("hello !{who}!")}
local r = tmpl.render(t, {["who"]="world"})
print(r) -- "hello world!"
assert(r=="hello world!")

-- same template, another data
local r2 = tmpl.render(t, {who="everybody"})
print(r2) -- "hello everybody!"
assert(r2=="hello everybody!")
print("ok")
