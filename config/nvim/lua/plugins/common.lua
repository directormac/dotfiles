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
    on_require = { 'nvim-web-devicons' },
    after = function(plugin) require('nvim-web-devicons').setup() end,
  },
  {
    'plenary.nvim',
    on_require = { 'plenary' },
  },
  {
    'nui.nvim',
    on_require = { 'nui' },
  },
  {
    'nvim-nio',
    on_require = { 'nio' },
  },
  {
    -- Configuration Reference https://github.com/gbprod/yanky.nvim#%EF%B8%8F-configuration
    'yanky.nvim',
    on_require = { 'yanky' },
  },
}
