-- Global keymaps.
-- See `:help vim.keymap.set()`

-- Keymaps for better default experience
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Moves Line Down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Moves Line Up' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll Down' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll Up' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next Search Result' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous Search Result' })

vim.keymap.set('n', '<leader><leader>[', '<cmd>bprev<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader><leader>]', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader><leader>l', '<cmd>b#<CR>', { desc = 'Last buffer' })
vim.keymap.set('n', '<leader><leader>d', '<cmd>bdelete<CR>', { desc = 'delete buffer' })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- kickstart.nvim starts you with this.
-- But it constantly clobbers your system clipboard whenever you delete anything.
-- It syncs clipboard between OS and Neovim.
--  See `:help 'clipboard'`
-- vim.o.clipboard = 'unnamedplus'

-- You should instead use these keybindings so that they are still easy to use, but dont conflict
vim.keymap.set({ 'v', 'x', 'n' }, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set(
  { 'n', 'v', 'x' },
  '<leader>Y',
  '"+yy',
  { noremap = true, silent = true, desc = 'Yank line to clipboard' }
)
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set(
  'i',
  '<C-p>',
  '<C-r><C-p>+',
  { noremap = true, silent = true, desc = 'Paste from clipboard from within insert mode' }
)
vim.keymap.set(
  'x',
  '<leader>P',
  '"_dP',
  { noremap = true, silent = true, desc = 'Paste over selection without erasing unnamed register' }
)

-- Quit neovim
vim.keymap.set('n', '<leader>qq', '<cmd>qa<CR>', { desc = 'Quit All' })
vim.keymap.set('n', '<leader>qf', '<cmd>noautocmd wqa!<CR>', { desc = 'Force write everything and Quit' })
vim.keymap.set('n', '<leader>qr', '<cmd>restart<CR>', { desc = 'Restart Neovim' })

vim.keymap.set(
  'n',
  '<leader>sp',
  '<cmd>lua nixInfo.lze.debug.display(nixInfo.plugins)<CR>',
  { desc = 'Show Lazy Plugins' }
)
