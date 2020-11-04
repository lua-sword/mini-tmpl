# mini-tmpl

## Features

Made to :
* be able to embedding data very strictly
* be able to deal with binary data
* be able to include sub-template
* support of empty tags (usefull for indentation)

No specific web encoding stuff

## Samples

```lua
local tmpl = require "mini-tmpl"
local a = tmpl.prepare("hello !{1}!")
local r = tmpl.render(a, {[1]="world"})
print(r) -- "hello world!"
```

```lua
local tmpl = require "mini-tmpl"
local templates = { tmpl.prepare("hello !{1}!") }
local a = tmpl.prepare("hello !{*>1}!")
local r = tmpl.render(a, {[1]="world"}, templates)
```

# end-of-line control

See the [README.eolcontrol.md](README.eolcontrol.md)
