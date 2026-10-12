require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/nvzone/showkeys' },
  })

  require('showkeys').setup({
    winhl = 'FloatBorder:Comment,Normal:Normal',
    timeout = 4,
    maxkeys = 5,
    position = 'bottom-center',
  })

  vim.keymap.set('n', '<leader>uk', '<cmd>ShowkeysToggle<CR>', { desc = 'Toggle showkeys', silent = true })
end)
