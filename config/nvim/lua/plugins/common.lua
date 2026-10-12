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
    on_require = { 'plenary' },
  },
  {
    'nui.nvim',
    lazy = true,
    on_require = { 'nui' },
  },
  {
    'nvim-nio',
    lazy = true,
    on_require = { 'nio' },
  },
}
