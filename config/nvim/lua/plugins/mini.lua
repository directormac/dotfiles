return {
  {
    'mini.nvim',
    auto_enable = true,
    event = 'DeferredUIEnter',
    after = function(plugin)
      -- Mini Icons
      require('mini.icons').setup()
      require('mini.bracketed').setup()
      require('mini.pairs').setup({
        modes = { insert = true, command = true, terminal = false },
      })
    end,
  },
}
