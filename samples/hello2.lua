local tmpl = require "mini-tmpl"

local a = tmpl.prepare("hello !{who}!")
local b = tmpl.render(a, {["who"]="world"})
print(b) -- "hello world!"
assert(b=="hello world!")

local b2 = tmpl.render(a, {who="everybody"})
print(b2) -- "hello everybody!"
assert(b2=="hello everybody!")
print("ok")
