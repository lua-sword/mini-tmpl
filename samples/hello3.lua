local tmpl = require "tmpl"

local temp_main = tmpl.prepare("hello !{peoples>peoples}.\n!{welcome}!")
local temp_peoples = tmpl.prepare("\n - !{1} !{2}")

local data = {
	welcome = "Nice to meet you",
	peoples = {
		{"John", "Smith"},
		{"foo", "bar"},
	},
}

local subtemplates = {
	peoples = temp_peoples,
}
local b = tmpl.render(temp_main, data, subtemplates)
print(b)
assert(b=="hello \n - John Smith\n - foo bar.\nNice to meet you!")
print("ok")
