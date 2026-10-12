-- Try to implement later https://github.com/zuqini/zpack.nvim

_G.Config = {
  -- mason = { "mdformat" },
  -- mason_extra = { "mdformat" },
  enable_profiler = vim.env.PROF,
}

-- Config.enable_profiler = 1
--
-- if Config.enable_profiler then
--   -- example for lazy.nvim
--   -- change this to the correct path for your plugin manager
--   local snacks = vim.fn.stdpath('data') .. '/site/pack/core/snacks.nvim'
--   vim.opt.rtp:append(snacks)
--   require('snacks.profiler').startup({
--     startup = {
--       event = 'VimEnter', -- stop profiler on this event. Defaults to `VimEnter`
--       -- event = "UIEnter",
--       -- event = "VeryLazy",
--     },
--   })
-- end

if vim.loader then vim.loader.enable() end

require('options')
require('keymaps')

require('autocmds')

-- -- Experimental: ui2 message/cmdline redesign (:h ui2)
-- -- Avoids "Press ENTER" prompts, highlights cmdline, pager as buffer.
-- require('vim._core.ui2').enable()
