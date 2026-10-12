return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = {
      options = {
        theme = 'auto',
        globalstatus = true,
        disabled_filetypes = { statusline = { 'dashboard', 'alpha' } },
        icons_enabled = true,
        component_separators = '',
        section_separators = '',
      },
      sections = {
        lualine_a = {
          {
            'mode',
            fmt = function()
              -- return "  "
              return '  '
            end,
          },
        },
        lualine_b = {
          { 'branch' },
        },
        lualine_z = {},
      },
      extensions = { 'lazy' },
    },
  },
}
