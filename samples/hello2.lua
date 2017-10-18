local tmpl = require "tmpl"

local a = tmpl.prepare("hello !{who}!")
local b = tmpl.render(a, {["who"]="world"})
print(b) -- "hello world!"

local b2 = tmpl.render(a, {who="everybody"})
print(b) -- "hello everybody!"

