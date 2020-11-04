return function(txt, eolchar)
	if not eolchar then eolchar="\n" end
	return (txt
		-- 1. all CRLF or CR => L
		:gsub("\r\n", "\n")
		:gsub("\r","\n")

		-- 2. how to get a litteral '!'
		:gsub("(!.)", function(a)
			if a=="!!" then return "!_" end
			if a=="!_" then
				return "!__"
				--error("!_ is unproperly quoted")
			end
			return a
		end)

		-- 3. Check template issue case
		:gsub("(![nrRl])[^\n]",function(a)
			error(a.." is unproperly quoted or must be followed by an end of line")
		end)

		-- 4. Remove all original end of line
		:gsub("\n","")

		-- 5. Make the end of line substitutions
		:gsub("(![nrRl])",function(b)
			if b=="!n" then return "\n" end
			if b=="!r" then return "\r" end
			if b=="!R" then return "\r\n" end
			if b=="!l" then return eolchar end
			error("eolcontrol: unattented case. (step 3 check evasion ?)")
		end)

		-- 6. unquote the '!' to finish the 2. job
		--	!_ => !   (unquote)
		:gsub("!_","!")
	)
end
