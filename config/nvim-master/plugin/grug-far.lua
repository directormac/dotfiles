require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/MagicDuck/grug-far.nvim', version = vim.version.range('*') },
  })

  require('grug-far').setup({
    engine = 'ripgrep',
  })

  vim.keymap.set({ 'n', 'x' }, '<leader>sr', function()
    local grug = require('grug-far')
    local ext = vim.bo.buftype == '' and vim.fn.expand('%:e')

    grug.open({
      transient = true,
      prefills = {
        filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
      },
    })
  end, { desc = 'Search and Replace' })
end)
