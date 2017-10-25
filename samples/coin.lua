local tmpl = require "tmpl"
local prep = tmpl.prepare

local COIN = prep "!{ COIN >o_- }"
local COINCOIN = {["o_-"] = prep("- !{1}\n")}

local b = tmpl.render( COIN,
{
	COIN={
		"Coin",
		"Coin Coin",
		"PAN! PAN!",
	}
}, COINCOIN)

io.stdout:write(b)
