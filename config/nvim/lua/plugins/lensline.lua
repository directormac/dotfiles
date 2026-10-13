return {
  {
    'lensline.nvim',
    event = 'LspAttach',
    opts = {
      profiles = {
        {
          name = 'basic',
          providers = {
            {
              name = 'usages',
              enabled = true,
              include = { 'refs', 'defs', 'impls' },
              breakdown = false,
              show_zero = false,
            },
            {
              name = 'diagnostics',
              enabled = true,
              min_level = 'WARN',
            },
            { name = 'last_author', enabled = true },
          },
          style = {
            placement = 'inline',
            render = 'focused',
          },
        },
        {
          name = 'informative',
          providers = {
            { name = 'usages', enabled = true, include = { 'refs', 'defs', 'impls' }, breakdown = true },
            { name = 'diagnostics', enabled = true, min_level = 'HINT' },
            { name = 'complexity', enabled = true },
          },
          style = { render = 'focused', placement = 'inline' },
        },
      },
    },
  },
}
