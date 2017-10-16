-- 1. all CRLF or CR => L
--	\r\n -> \n
--	\r -> \n
--
-- 2. how to get a litteral '!'
--	!! => !_  (quoted '!')
--	!_ => !__ (unquoting workaround)
--
-- 3. Check template issue case
--	find ![nrR][^\n]  => error if found
--
-- 4. Remove all original end of line
--
-- 5. Make the end of line substitutions
--	!R + \n -> \r\n
--	!n + \n -> \n
--	!r + \n -> \r
--
-- 6. unquote the '!' to finish the 2. job
--	!_ => !   (unquote)

return function(txt)
	return (txt
		-- 1. all CRLF or CR => L
		:gsub("\r\n", "\n")
		:gsub("\r","\n")

		-- 2. how to get a litteral '!'
		--:gsub("!!","!_")
		:gsub("(!.)", function(a)
			if a=="!!" then return "!_" end
			if a=="!_" then
				return "!__"
				--error("!_ is unproperly quoted")
			end
			return a
		end)

		-- 3. Check template issue case
		:gsub("(![nrR])[^\n]",function(a)
			error(a.." is unproperly quoted or must be followed by an end of line")
		end)

		-- 4. Remove all original end of line
		:gsub("\n","")

		-- 5. Make the end of line substitutions
		:gsub("(![nrR])",function(b)
			if b=="!n" then return "\n" end
			if b=="!r" then return "\r" end
			if b=="!R" then return "\r\n" end
			error("should not append")
		end)

		-- 6. unquote the '!' to finish the 2. job
		--	!_ => !   (unquote)
		:gsub("!_","!")
	)
end

-- 'foo!n\nbar'		=> 'foo\nbar'
-- 'foo!!n\nbar'	=> 'foo!nbar'
-- 'foo!!n!n\nbar'	=> 'foo!n\nbar'
-- 'foo!n!!n\nbar'	=> error "!n is unproperly quoted or must be followed by a end of line"
-- 'foo!n\n!!n\nbar'	=> 'foo\n!!nbar'

-- '!!' => '!'
-- '!_' => '!_'
-- '!!_' => '!_'
-- '!!!_' => '!!_'
