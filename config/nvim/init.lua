-- Ordering only. Layout:
--   lua/config/  bootstrap, options, keymaps, shared utils
--   plugin/      one file per plugin, each registers its own lze spec (auto-sourced)
--   lsp/         server settings, merged by vim.lsp.config (see :h lsp-config-merge)
--   ftplugin/    filetype settings      after/  overrides, applied last
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
_G.__startup_time = vim.uv.hrtime()
vim.loader.enable() -- <- bytecode caching

require('config.bootstrap')
require('config.options')
require('config.keymaps')
