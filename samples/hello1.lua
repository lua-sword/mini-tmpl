local tmpl = require "tmpl"
local a = tmpl.prepare("hello !{1}!")
local b = tmpl.render(a, {[1]="world"})
print(b) -- "hello world!"

