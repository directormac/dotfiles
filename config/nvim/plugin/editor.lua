-- Runtime plugin script: sourced automatically from 'runtimepath' after init.lua.
-- Editor-level globals and autocmds that do not depend on any plugin.

-- [[ Disable auto comment on enter ]]
-- See :help formatoptions
vim.api.nvim_create_autocmd('FileType', {
  desc = 'remove formatoptions',
  callback = function() vim.opt.formatoptions:remove({ 'c', 'r', 'o' }) end,
})

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank() end,
  group = highlight_group,
  pattern = '*',
})

vim.g.netrw_liststyle = 0
vim.g.netrw_banner = 0
