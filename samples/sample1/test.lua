local tmpl = require "mini-tmpl"
--local main = require "ast-tmpl.main"
local main = tmpl.prepare( require "txt-tmpl.main" )

local r = tmpl.render(main, {
	foot="FOOTER\n",
	body="BODY\n",
	head="HEADER\n",
})
io.stdout:write(r)
