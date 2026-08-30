require('lazyload').on_vim_enter(function()
  vim.pack.add({ 'https://github.com/folke/flash.nvim' })

  require('flash').setup({})

  vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash' })
  vim.keymap.set({ 'n', 'o', 'x' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash Treesitter' })
  vim.keymap.set('o', 'r', function() require('flash').remote() end, { desc = 'Remote Flash' })
  vim.keymap.set({ 'o', 'x' }, 'R', function() require('flash').treesitter_search() end, { desc = 'Treesitter Search' })
  vim.keymap.set('c', '<c-s>', function() require('flash').togge() end, { desc = 'Toggle Flash Search' })

  vim.keymap.set(
    { 'n', 'o', 'x' },
    '<c-space>',
    function()
      require('flash').treesitter({
        actions = {
          ['<c-space>'] = 'next',
          ['<BS>'] = 'prev',
        },
      })
    end,
    { desc = '"Treesitter Incremental Selection' }
  )
end)
