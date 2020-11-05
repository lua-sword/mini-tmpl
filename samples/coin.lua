local tmpl = require "mini-tmpl"

local COIN = tmpl.prepare "!{ COIN >o_- }"
local COINCOIN = {
	COIN,
	["o_-"] = tmpl.prepare "- !{1}\n"
}

local r = tmpl.render(COINCOIN, {
	COIN={
		"Coin",
		"Coin Coin",
		"PAN! PAN!",
	}
})

io.stdout:write(r)
assert(r=="- Coin\n- Coin Coin\n- PAN! PAN!\n")
print("ok")
