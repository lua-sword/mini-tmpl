
local M = {}
M._VERSION = "mini-tmpl.prepare 0.5.0"

local const = assert(require "mini-tmpl.common".const)

M.openmark = '!{' -- if you change them, thing to quote them for lua pattern
M.closemark = '}'
M.special = ">|"

local mkast = assert(require "mini-tmpl.mkast")
local mkast_static = mkast.static
local mkast_var = mkast.var
local mkast_loop = mkast.loop
local mkast_include = mkast.include2
local mkast_template = mkast.template

local function trim(s)
	return s:match("^%s*(.*%S)" or "")
end

-- split content inside a mark : "^foo|bar>buz" -> {"^foo","|","bar",">","buz"}
local function splitmarkcontent(data)
	local insert = table.insert
	local result = {}
	local trailing = data:gsub("(["..M.special.."]?)([^"..M.special.."]+)", function(a,b)
		if a ~= "" then insert(result, a) end
		insert(result, trim(b))
		return ""
	end)
	insert(result, trim(trailing))
	return result
end
assert(require"tprint"(splitmarkcontent("^foo|bar>buz")==[[{"^foo","|","bar",">","buz",}]]))
assert(require"tprint"(splitmarkcontent(">foo"))==[[{">","foo",}]])
--print( require"tprint"(splitmarkcontent( "^ .fo .foo > ba bar | bu buz>\"baz toto\" titi | " )) ) os.exit()

local function prepare(txt_tmpl, force)
	assert(type(txt_tmpl)=="string", "invalid template type, must be a string")
	local content = {}
	local add = function(item) table.insert(content, item) end

	local pat = "(.-)"..M.openmark.."(.-)".. M.closemark
	local trailing = string.gsub(txt_tmpl, pat, function(pre,value)
		-- pre: the text before a !{...} mark
		-- value: the value inside the mark

		if pre and pre~="" then
			add(mkast_static(pre))
		end

		local items = splitmarkcontent(value)

		local function isTemplate(x)
			return x == ">"
		end
		local function isFunc(x)
			return x == "|"
		end

		local use_func, use_template = false,false
		local v,f,t -- var, function, template

		--[[
		local function shift() table.remove(items, 1) end
		local function get() return items[1] end
		while #items > 0 do
		]]--

		local pos = 1
		local function shift() pos=pos+1 end
		local function get() return items[pos] end
		while pos <= #items do

			if isTemplate(get()) then
				use_template = true;	shift()
				t = get(); 		shift()
			elseif isFunc(get()) then
				use_func = true;	shift()
				f = get();		shift()
			else
				if v then
					error("varname already exists!")
				end
				v = get();		shift()
			end
		end

		if (not v or v == "") and (use_func) then -- or use_template ? no, allow !{>footer} to include static content
			v="1" -- default value
		end
		if use_func and (not f or f=="")then
			f="1"
		end
		if use_template and (not t or t=="")then
			t="1"
		end

		local pv=v and v:sub(1,1)
		local scope="local"
		if pv and pv == "." then
			scope="meta"
			v=trim(v:sub(2)) -- ". varname" -> "varname"
		elseif pv and pv == "^" then
			scope="global"
			v=trim(v:sub(2)) -- "^ varname" -> "varname"
		end

		--print("scope", scope)
		--print("var",    v)
		--print("func",   f)
		--print("templ",  t)
		--print("use_func", use_func, "use_template", use_template)

		-- avoid !{} or !{<spaces>} cases
		if v and v~= "" then
			if v:find("^[0-9]+$") then -- is a base10 number
				v = assert(tonumber(v, 10), "fail to convert base10 number")
			end
			if t then
				add(mkast_loop(v, t))
			else
				add(mkast_var(v, scope))
			end
		elseif t then
			add(mkast_include(t))
		end
		return ""
	end)
	if trailing and trailing~="" then
		if not force and trailing==txt_tmpl then
			io.stderr:write("Warning: the template seems not parsed at all\n")
			io.stderr:write(txt_tmpl.."\n")
			--error("Warning: the template seems not parsed at all",2)
		end
		add(mkast_static(trailing))
	end
	local ast = mkast_template(nil, content)
	return ast
end
M.prepare = prepare

-- expose them (internaly not affected if overwritten)
M.static = static
M.var = var
M.loop = loop
M.include = include

setmetatable(M, {__call=function(_, ...) return prepare(...) end})

return M
