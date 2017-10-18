# mini tmpl

## Features

Made to :
* be able to embedding data very strictly
* be able to deal with binary data
* be able to include sub-template
* support of empty tags (usefull for indentation)

No specific web encoding stuff

## Samples

```lua
local tmpl = require "tmpl"
local a = tmpl.prepare("hello !{1}!")
local b = tmpl.render(a, {[1]="world"})
print(b) -- "hello world!"
```


# end-of-line control

See the [README.eolcontrol.md](README.eolcontrol.md)
