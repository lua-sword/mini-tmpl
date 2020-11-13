local tmpl = require "mini-tmpl"
local templates = {
	a = tmpl.prepare("!{>b}"),
	b = tmpl.prepare("!{>c}"),
	c = tmpl.prepare("hello !{1}!"),
}
local r = tmpl.render(templates, {[1]="world"}, nil, {main="a"})
print(r)
