return {
  'lensline.nvim',
  event = 'LspAttach',
  after = function()
    -- https://github.com/oribarilan/lensline.nvim/blob/main/README.md
    -- https://github.com/oribarilan/lensline.nvim/blob/main/providers.md
    require('lensline').setup({
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
              enabled = true, -- Must be explicitly enabled
              min_level = 'WARN', -- Only show errors
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
    })
  end,
}
