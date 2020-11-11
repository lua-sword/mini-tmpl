
-- list ->
-- actuellement on a 	=> !{.i} !{1}
-- i,v
-- pour i on a .i ?
-- _G ; _L? ;
--    {[0]=i, [1]=v}	=> !{0} !{1}
-- ou {[1]=i, [2]=v}		=> !{1} !{2}
-- ou {i=i,     v=v}	=> !{i} !{v}
-- ou {i=i,   [1]=v}   	=> !{i} !{1}
-- on pourrait passer 2 arguments a la fonction, global et current ?
-- par default current==global
-- mais dans une boucle, current est crafté ...
-- comment accèder a "i" ?
-- comment acceder au niveau parent ?
-- on boucle et on veut ../separateur ?
-- current = {[".."]=parent, ["_G"]=db, [0]=i_or_k, [1]=v,   }
-- db =      {[".."]=db,     ["_G"]=db, [0]=nil,    [1]=..., }

-- varname -> list -> loop(list)
-- ast: {1<type>, 2<args(=3)>, 2<k>, 3<templatename>, 4<dynamicfield>, 5...}
local function loopDynamic(ast, parent, current)
	assert(type(ast[1])=="number")
	local astargs = assert(ast[2])
	assert(astargs==3)
	local render = assert(parent.render)

	local k = assert(ast[3])
	assert( k and k~="" )

	local templatename = assert(ast[4])
	assert( templatename and templatename~="" )

	local dynamicfield = assert(
		ast[5] or parent.config.dynamicfield, "missing dynamicfield")

	local templates = assert(parent.templates)
	local template = templates[templatename] -- try with k as string else convert k to number

	if not template and type(templatename)=="string" and templatename:find("^[0-9]+$") then -- is a base10 number
--print("TRY to convert the template name from string to number")
		local templatename = tonumber(templatename, 10)
		template = templatename and templates[templatename]
	end
	assert(type(template)=="table")
	local rootvalues = assert(parent.rootvalues)
	local list = rootvalues[k] or {""}
--	if k=="*" then
--		io.stderr:write("Warning k is a star!")
--		return render(template, parent, current)
--	end

	local dynamic = nil
	local subtemplatesparent = nil
	if type(template[dynamicfield])=="function" then
		--Dprint("DEBUG: template[dynamicfield] FOUND!")
		dynamic = template[dynamicfield]
		subtemplatesparent = template
		assert(type(subtemplatesparent)=="table")
	end
	local r = {}
	for i,item in ipairs(list) do
		-- dispatch function + sub templates
		if dynamic then
			local searchinto, name = dynamic(i, #list)
			if name==nil and searchinto then -- compat: when only one argument is returned, consider that is name
				name,searchinto = searchinto,nil
			end
			assert(name, "dynamic function must return 2 arguments, subtemplate name is missing")
			local subtemplates = subtemplatesparent
			if searchinto then -- if searchinto==false|nil search into the parent
				assert(type(searchinto)=="string" or type(searchinto)=="number")
				--Dprint("searchinto=", searchinto)
				assert(type(subtemplatesparent[searchinto])=="table", "subtemplatesparent[searchinto] must be a table, found: "..type(subtemplatesparent[searchinto]))
				subtemplates = subtemplatesparent[searchinto]
			end
			assert(type(subtemplates)=="table")
			if subtemplates[name] then
				template = subtemplates[name]
			end
		else
			--Dprint("DEBUG: NO dynamic")
		end
		local item2=item
		if type(item)=="string" then
			--Dprint("convert item from", item)
			item2={item,i=tostring(i)}
			--Dprint("to", tprint(item))
		end
		local values2 = {["meta"]={i=tostring(i)}, ["local"]=item2, ["global"]=rootvalues,}
parent.rootvalues = values2
		table.insert(r, render(template, parent, current)) -- fallback value item => setmetatable(item, {__index=rootvalues})
	end
	return table.concat(r,"")
end
return loopDynamic
