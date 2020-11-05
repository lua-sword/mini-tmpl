local tmpl = require "mini-tmpl"
local a = tmpl.prepare("hello !{1}!")
print(require"tprint"(a,{inline=false}))
local r = tmpl.render(a, {[1]="world"})
print(r) -- "hello world!"
assert(r=="hello world!")
print("ok")
