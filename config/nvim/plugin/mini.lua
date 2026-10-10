nixInfo.lze.load({
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
})

nixInfo.lze.load({
  {
    'otter.nvim',
    auto_enable = true,
    event = 'DeferredUIEnter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    after = function(plugin) require('otter').setup() end,
  },
})
