return {
  {
    'render-markdown.nvim',
    after = function()
      ---@module 'render-markdown'
      ---@type render.md.UserConfig
      require('render-markdown').setup({

        code = {
          render_modes = true,
          conceal_delimiters = false,
          border = 'thick',
        },
      })
    end,
  },
}
