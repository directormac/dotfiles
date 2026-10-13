-- Ordering only. Layout:
--   lua/config/   bootstrap, options, keymaps, autocmds, diagnostics, shared utils
--   lua/plugins/  one file per plugin, returning pure lz.n specs (return { ... })
--   lsp/          server settings, merged by vim.lsp.config (see :h lsp-config-merge)
--   ftplugin/     filetype settings      after/  overrides, applied last
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

if vim.env.NVIM_PROFILER then
  -- Nix wrapper installs snacks.nvim as a startup plugin (lazy = false in
  -- neovim.nix), so it's already on the runtimepath here. No rtp append needed.
  require('snacks.profiler').startup({
    startup = {
      event = 'VimEnter',
      -- event = 'DeferredUIEnter', -- stop profiling at this event
    },
  })
end

_G.__startup_time = vim.uv.hrtime()
vim.loader.enable() -- <- bytecode caching

require('config.bootstrap')
require('config.options')
require('config.filetypes')
require('config.keymaps')
require('config.autocmds')
require('config.diagnostics')

-- Load all plugin specs from lua/plugins/ via lz.n
require('lz.n').load('plugins')

-- Apply colorscheme (lazily loaded via lz.n colorscheme handler)
vim.cmd.colorscheme(nixInfo('catppuccin', 'settings', 'colorscheme'))

local ok_ar, lzn_ar = pcall(require, 'lzn-auto-require')
if ok_ar then lzn_ar.enable() end
