
local M = {}
M._VERSION = "mini-tmpl 0.4.0"

M.prepare_mod = require "mini-tmpl.prepare"
M.render_mod = require "mini-tmpl.render"
M.astrender_mod = require "mini-tmpl.astrender"

M.prepare = M.prepare_mod.prepare
M.render = M.render_mod.render

return M
