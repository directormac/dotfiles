return {
  {
    'mini.nvim',
    event = 'DeferredUIEnter',
    after = function(plugin)
      require('mini.icons').setup()
      require('mini.bracketed').setup()
      require('mini.pairs').setup({
        modes = { insert = true, command = true, terminal = false },
      })
    end,
  },
  {
    'otter.nvim',
    event = 'DeferredUIEnter',
    after = function(plugin) require('otter').setup() end,
  },
}
