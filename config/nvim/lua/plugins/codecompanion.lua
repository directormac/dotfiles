return {
  {
    -- Documentation https://codecompanion.olimorris.dev/getting-started
    'codecompanion.nvim',
    cmd = { 'CodeCompanion', 'CodeCompanionActions', 'CodeCompanionChat', 'CodeCompanionCmd' },
    after = function()
      -- Configuration Reference https://codecompanion.olimorris.dev/configuration/action-palette
      require('codecompanion').setup({})
    end,
  },
}
