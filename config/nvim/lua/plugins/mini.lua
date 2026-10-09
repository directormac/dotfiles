return {
  {
    'mini.nvim',
    auto_enable = true,
    event = 'DeferredUIEnter',
    after = function(plugin)
      -- Mini Icons
      require('mini.icons').setup()
    end,
  },
}
