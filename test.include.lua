local tmpl = require "mini-tmpl"
local a = tmpl.prepare("!{>b}")
local templates = { a, b = tmpl.prepare("hello !{1}!") }
--print(require"tprint"(a,{inline=false}))
local r = tmpl.render(templates, {[1]="world"})
print(r)
assert(r=="hello world!")
