require('lazyload').on_vim_enter(function()
  vim.pack.add({ 'https://github.com/stevearc/oil.nvim' })

  ---@type oil.SetupOpts
  require('oil').setup({
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

  vim.keymap.set('n', '<leader>fo', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
  vim.keymap.set('n', '<leader>fO', '<CMD>Oil .<CR>', { desc = 'Open parent directory' })

  -- find
  vim.keymap.set('n', '<leader>fe', function() Snacks.explorer() end, { desc = 'File Explorer' })
  vim.keymap.set('n', '<leader>fb', function() Snacks.picker.buffers() end, { desc = 'Buffers' })
  vim.keymap.set(
    'n',
    '<leader>fc',
    function() Snacks.picker.files({ cwd = vim.fn.stdpath('config') }) end,
    { desc = 'Find Config File' }
  )
  vim.keymap.set('n', '<leader>ff', function() Snacks.picker.files() end, { desc = 'Find Files' })
  vim.keymap.set('n', '<leader>fg', function() Snacks.picker.git_files() end, { desc = 'Find Git Files' })
  vim.keymap.set('n', '<leader>fp', function() Snacks.picker.projects() end, { desc = 'Projects' })
  vim.keymap.set(
    'n',
    '<leader>fr',
    function() Snacks.picker.recent({ filter = { cwd = true } }) end,
    { desc = 'Recent' }
  )
end)
