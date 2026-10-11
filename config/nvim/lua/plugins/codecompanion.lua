return {
  {
    -- Documentation https://codecompanion.olimorris.dev/getting-started
    'codecompanion.nvim',

    before = function()
      require('lz.n').trigger_load({
        'plenary.nvim',
      })
    end,
    after = function()
      -- Configuration Reference https://codecompanion.olimorris.dev/configuration/action-palette
      require('codecompanion').setup({})
    end,
  },
  {
    'plenary.nvim',
    lazy = true,
  },
}
