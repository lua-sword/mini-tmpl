local tmpl = require "mini-tmpl"

local temp_main = tmpl.prepare("hello !{peoples>peoples}.\n!{welcome}!")
local temp_peoples = tmpl.prepare("\n - !{1} !{2}")

local data = {
	welcome = "Nice to meet you",
	peoples = {
		{"John", "Smith"},
		{"foo", "bar"},
	},
}

local templates = {
	temp_main,
	peoples = temp_peoples,
}
local r = tmpl.render(templates, data)
print(r)
assert(r=="hello \n - John Smith\n - foo bar.\nNice to meet you!")
print("ok")
