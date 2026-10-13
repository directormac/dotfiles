return {
  'snacks.nvim',

  keys = {
    { '<leader>e', function() Snacks.explorer.open() end, desc = 'File Explorer (Snacks)' },
  },

  opts = {
    explorer = {
      -- replace_netrw = true,
    },
    picker = {
      sources = {
        explorer = {
          auto_close = true,
        },
      },
    },
  },
}
