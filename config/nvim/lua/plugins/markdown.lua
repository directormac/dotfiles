return {
  {
    'render-markdown.nvim',
    after = function()
      --- https://github.com/meanderingprogrammer/render-markdown.nvim#setup
      ---@module 'render-markdown'
      ---@type render.md.UserConfig
      require('render-markdown').setup({
        completions = { lsp = { enabled = true } },
        code = {
          render_modes = true,
          conceal_delimiters = false,
          border = 'thick',
        },
      })
    end,
  },
}
