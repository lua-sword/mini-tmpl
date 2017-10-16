local tmpl = require "tmpl"
local eolcontrol = tmpl.eolcontrol

--local main = require "ast-tmpl.main"
local templates = {}
if true then
	--templates._main = tmpl.prepare(require "txt-tmpl.main":gsub("[\r\n]",""):gsub("!{\\n}","\n") )
	--templates.tlist = tmpl.prepare( require "txt-tmpl.tlist":gsub("[\r\n]",""):gsub("!{\\n}","\n") ) -- :gsub("[\r\n]",""):gsub("!{\\n}", "!{nl}") )

	templates._main = tmpl.prepare( eolcontrol(require "txt-tmpl.main") )
	templates.tlist = tmpl.prepare( eolcontrol(require "txt-tmpl.tlist") )

--	local tprint = require"tprint"
--	print(tprint(templates._main))
--	print(tprint(templates.tlist))
else
	templates._main = {
		tag="template",
		"# begin\n",
		{tag="mark", "head"},
		{tag="loop", "list", "tlist"},
		{tag="mark", "foot"},
		"# end\n",
	}
	templates.tlist = {
		tag="template",
		" * ",
		{tag="mark", 1},
		" = ",
		{tag="mark", 2},
		"\n",
	}
end

local data =  {
	foot="FOOTER\n",
	body="BODY\n",
	head="HEADER\n",
	list={
		{"a", "A"},
		{"b", "B"},
	},
	["nl"]="\n",
}

local r = tmpl.render(templates._main, data, templates)
io.stdout:write(r)
