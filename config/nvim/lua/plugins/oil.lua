---@type oil.SetupOpts
require('oil.nvim').setup({
  default_file_explorer = true,
  columns = {
    'icon',
    'size',
  },
  -- Skip the confirmation popup for simple operations
  skip_confirm_for_simple_edits = true,
  keymaps = {
    ['q'] = 'actions.close',
    ['<C-s>'] = false,
  },
  view_options = {
    show_hidden = true,
  },
})

vim.keymap.set('n', '<leader>fo', '<CMD>Oil<CR>', { desc = 'Open cwd.' })
vim.keymap.set('n', '<leader>fO', '<CMD>Oil .<CR>', { desc = 'Open parent directory' })
