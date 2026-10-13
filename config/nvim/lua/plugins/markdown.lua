return {
  {
    'render-markdown.nvim',
    ft = { 'markdown', 'codecompanion' },
    cmd = { 'RenderMarkdown' },
    opts = {
      completions = { lsp = { enabled = true } },
      code = {
        render_modes = true,
        conceal_delimiters = false,
        border = 'thick',
      },
    },
  },
}
