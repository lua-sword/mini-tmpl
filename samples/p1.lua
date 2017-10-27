local tmpl = require "tmpl"
local tprint = require "tprint"
local a = tmpl.prepare("hello !{ 1 ign1 | foo ign2 > templ1 ign3 }!")
local a = tmpl.prepare("hello !{ 1 | foo > templ1}!")
local a = tmpl.prepare("hello !{1|foo>templ1}!")
local a = tmpl.prepare("hello !{1>templ1}!")
local a = tmpl.prepare("hello !{>templ1}!")
local a = tmpl.prepare("hello !{var1}!")
local a = tmpl.prepare("hello !{|foo>}!")
local a = tmpl.prepare("hello !{|>}!")
local a = tmpl.prepare("hello !{|}!")
local a = tmpl.prepare("hello !{>}!")

--print(tprint(a))
--local b = tmpl.render(a, {[1]="world"})
--print(b) -- "hello world!"
--assert(b=="hello world!")
print("ok")
