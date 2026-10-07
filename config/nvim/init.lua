-- NOTE: Welcome to your neovim configuration!
-- This file only handles ordering. Everything else lives in:
--   lua/config/   bootstrap, options, keymaps, plugin entrypoint
--   lua/plugins/  lazy.nvim (lze) specs
--   lua/lsp/      lsp specs
--   lsp/          server settings, merged from 'runtimepath'
--   plugin/       runtime plugin scripts
--   ftplugin/     filetype settings
--   after/        overrides, applied last

vim.loader.enable() -- <- bytecode caching

-- nixInfo + lze + the spec handlers everything else depends on
require('config.bootstrap')
-- options and keymaps, before any plugin that binds keys
require('config.options')
require('config.keymaps')
-- the specs themselves
require('config.plugins')
