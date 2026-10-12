vim.pack.add({ 'https://github.com/folke/persistence.nvim' })

---@type Persistence.Config
require('persistence').setup({})

vim.keymap.set('n', '<leader>qs', function() require('persistence').load() end, { desc = 'Restore Session' })

vim.keymap.set(
  'n',
  '<leader>qS',
  function() require('persistence').select() end,
  { desc = 'Select and load a session.' }
)
vim.keymap.set(
  'n',
  '<leader>ql',
  function() require('persistence').load({ last = true }) end,
  { desc = 'Restore Last Session' }
)

-- stop Persistence => session won't be saved on exit
vim.keymap.set('n', '<leader>qd', function() require('persistence').stop() end, { desc = "Don't Save Current Session" })
