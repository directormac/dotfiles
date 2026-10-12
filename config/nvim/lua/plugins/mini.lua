return {
  'mini.nvim',
  lazy = false,
  after = function(plugin)
    require('mini.icons').setup()
    require('mini.bracketed').setup()
  end,
}
