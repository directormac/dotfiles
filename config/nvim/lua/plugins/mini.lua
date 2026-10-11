return {
  {
    'mini.nvim',
    event = 'DeferredUIEnter',
    after = function(plugin)
      require('mini.icons').setup()
      require('mini.bracketed').setup()
    end,
  },
  {
    'otter.nvim',
    event = 'DeferredUIEnter',
    after = function(plugin) require('otter').setup() end,
  },
}
