local tmpl = require "mini-tmpl"

local templates = {
	[1] = tmpl.prepare([[!{1>1}]]);		-- the main template
	["1"] = tmpl.prepare([[- !{1}!{^l}]]);	-- the 2nd template named "1" call by !{...>1}
}

local data = {
	{					-- the data[1] use by the main template !{1>...}
		"line 1",			-- the first item. !{1} of the 2nd template
		"line 2",			-- also !{1} of 2nd template
		"line 3",			-- also !{1} of 2nd template
	},
	l="\n",					-- the upvalue got by !{^l} from the 2nd template
}

local r = tmpl.render(templates,data)
io.stdout:write(r)
assert(r=="- line 1\n- line 2\n- line 3\n")
print("ok")
