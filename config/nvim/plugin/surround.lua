nixInfo.lze.load({
  {
    'nvim-surround',
    auto_enable = true,
    event = 'DeferredUIEnter',
    after = function(plugin) require('nvim-surround').setup() end,
  },
})
