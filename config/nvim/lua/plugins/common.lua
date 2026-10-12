return {
  {
    'mini.nvim',
    lazy = false,
    after = function(plugin)
      require('mini.icons').setup()
      require('mini.bracketed').setup()
    end,
  },
  {
    'nvim-web-devicons',
    lazy = false,
    after = function(plugin) require('nvim-web-devicons').setup() end,
  },
  {
    'plenary.nvim',
    lazy = true,
  },
}
