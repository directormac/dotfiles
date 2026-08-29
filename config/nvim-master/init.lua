-- Try to implement later https://github.com/zuqini/zpack.nvim

_G.Config = {
  -- mason = { "mdformat" },
  -- mason_extra = { "mdformat" },
}

if vim.loader then vim.loader.enable() end

require('options')
require('keymaps')

require('autocmds')

-- -- Experimental: ui2 message/cmdline redesign (:h ui2)
-- -- Avoids "Press ENTER" prompts, highlights cmdline, pager as buffer.
-- require('vim._core.ui2').enable()
