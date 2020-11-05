local tmpl = require "mini-tmpl"
local t = {tmpl.prepare("hello !{1}!")}
--print(require"tprint"(t,{inline=false}))
local r = tmpl.render(t, {[1]="world"})
print(r) -- "hello world!"
assert(r=="hello world!")
print("ok")
