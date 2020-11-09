local tmpl = require "mini-tmpl"
local templates = {
	tmpl.prepare("!{>b}"),
	b = tmpl.prepare("hello !{1}!"),
}
-- print(require"tprint"(a,{inline=false}))
local r = tmpl.render(templates, {[1]="world"})
print(r)
