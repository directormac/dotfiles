-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = function(mode, lhs, rhs, opts)
  local keys = require('lazy.core.handler').handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then opts.remap = nil end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

map({ 'n', 'v' }, '<C-x>', '"+y<esc>dd', { noremap = true, desc = 'Copy and delete line' })
map({ 'n', 'v' }, '<C-y>', '"+yy<esc>', { noremap = true, desc = 'Copy' })
map({ 'n' }, '<C-p>', '"+p<esc>', { noremap = true, desc = 'Paste' })
map('v', 'x', '"_x', { noremap = true, silent = true, desc = 'Delete character without yanking' })

map(
  'n',
  'x', -- Also let's allow 'x' key to delete blank lines in normal mode.
  function()
    if vim.fn.col('.') == 1 then
      local line = vim.fn.getline('.')
      if line:match('^%s*$') then
        vim.api.nvim_feedkeys('dd', 'n', false)
        vim.api.nvim_feedkeys('$', 'n', false)
      else
        vim.api.nvim_feedkeys('"_x', 'n', false)
      end
    else
      vim.api.nvim_feedkeys('"_x', 'n', false)
    end
  end,
  { noremap = true, silent = true, desc = 'Delete blank line without yanking' }
)

-- Blazingly fast way out of insert mode and terminal mode
map('i', '<C-c>', '<esc>')

map('t', '<Esc>', '<C-\\><C-n>', { noremap = true, desc = 'Escape Insert Mode' })

-- Beter scrolllssssssss
map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center cursor' })
map('n', '<C-u>', '<C-u>zz', { desc = ' up and center cursor' })

-- Tabulation in visual mode
map('v', '<S-Tab>', '<gv', { desc = 'Unindent line' })
map('v', '<Tab>', '>gv', { desc = 'Indent line' })

map('n', '<leader>cq', function()
  vim.cmd('lsp restart')
  vim.notify('LSP restarted', vim.log.levels.INFO, { title = 'LSP' })
end, { desc = 'Restart Lsp' })
