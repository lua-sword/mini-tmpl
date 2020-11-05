local tmpl = require "mini-tmpl"
local a = tmpl.prepare("!{>b}")
local templates = { b = tmpl.prepare("hello !{1}!") }
print(require"tprint"(a,{inline=false}))
local r = tmpl.render(a, {[1]="world"}, templates)
print(r)
