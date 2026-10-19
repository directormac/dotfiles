return {
  {
    'render-markdown.nvim',
    ft = { 'markdown', 'codecompanion' },
    cmd = { 'RenderMarkdown' },
    opts = {
      file_types = { 'markdown', 'codecompanion', 'nix' },
      completions = { lsp = { enabled = true } },
      code = {
        render_modes = true,
        conceal_delimiters = false,
        border = 'thick',
      },
    },
  },
}
