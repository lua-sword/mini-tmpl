# end-of-line control

## What is it ?

It's an additionnal utility to help to get exactly the data you want focused on the end-of-line problem.

A end of line is :
* `\r\n` for Windows (CRLF)
* `\r` for MacOS (CR)
* `\n` for Linux (LF)

eolcontrol allow you to place special marks to always get the same result (platform independent)

## Syntaxe

Use any kind of end-of-line in your template, even mixed.

* `!R` for a Windows line (CRLF)
* `!r` for MacOS line (CR)
* `!n` for Unix/Linux line (LF)
* `!l` for the end-of-line you will pass to eolcontrol (or Unix/Linux if omited)
* `!!` to get a litteral `!`

## Sample

```lua
local eolcontrol = require "tmpl.eolcontrol"

assert(eolcontrol([[
FOO!R
BAR
]]) == "FOO".."\r\n".."BAR")

assert(eolcontrol([[
FOO!n
BAR
]]) == "FOO".."\n".."BAR")

assert(eolcontrol([[
FOO!r
BAR
]]) == "foo".."\r".."BAR")

local x =[[
FOO!l
BAR
]]
assert( eolcontrol(x, "\r\n") == "FOO\r\nBAR")
assert( eolcontrol(x, "\r")   == "FOO\rBAR")
assert( eolcontrol(x, "\n")   == "FOO\nBAR")
```

## How to use

### Force Windows end-of-line

```lua
local x = eofcontrol[[
line 1!R
line 2!R
]]
```

To get

```
line 1\r\n
line 2\r\n
```


### Force MacOS end-of-line

```lua
local x = eofcontrol[[
line 1!r
line 2!r
]]
```

To get

```
line 1\r
line 2\r
```

### Force Linux end-of-line

```lua
local x = eofcontrol[[
line 1!n
line 2!n
]]
```

To get

```
line 1\n
line 2\n
```

### Force a Custom end-of-line

```lua
local x = eofcontrol([[
line 1!l
line 2!l
]], "\0")
```

To get

```
line 1\0
line 2\0
```


## Mix them all

```lua
local x = [[

windows line!R

macos line!r

linux line!n

]]
```

will always be rendered as
```
windows line\r\n
macos line\r
linux line\n
```

All other end-of-line are removed, then you can split lines like

```lua
local x = eofcontrol([[

line
 1!l

line 2!l]], "\n")
```

