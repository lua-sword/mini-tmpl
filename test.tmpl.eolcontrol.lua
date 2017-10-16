local E = require "tmpl.eolcontrol"

-- 'foo!n\nbar'         => 'foo\nbar'
-- 'foo!!n\nbar'        => 'foo!nbar'
-- 'foo!!n!n\nbar'      => 'foo!n\nbar'
-- 'foo!n!!n\nbar'      => error "!n is unproperly quoted or must be followed by a end of line"
-- 'foo!n\n!!n\nbar'    => 'foo\n!!nbar'

assert(E('foo!n\nbar') == 'foo\nbar')
assert(E('foo!!n\nbar') == 'foo!nbar')
assert(E('foo!!n!n\nbar') == 'foo!n\nbar')
local ok, msg = pcall(E, 'foo!n!!n\nbar'); assert(not ok and (msg:find("!n is unproperly quoted or must be followed by an end of line",nil,true)))
assert(E('foo!n\n!!n\nbar') == 'foo\n!nbar')

-- '\r\n\n\r' => ''
assert(E('\r\n\n\r')=="")

assert(E('!!') == '!')
assert(E('!!_') == '!_')

assert(E('!@') == '!@')
assert(E('!!!@') == '!!@')

assert(E('!_') == '!_')
assert(E('!_\n') == '!_')
assert(E('!!!_') == '!!_') -- wrongly quoted but autofixed
assert(E('!!!_\n') == '!!_') -- wrongly quoted but autofixed
print("ok")
