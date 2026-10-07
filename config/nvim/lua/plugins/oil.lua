return {
  {
    'oil.nvim',
    auto_enable = true,
    keys = {
      {
        '<leader>fo',
        '<cmd>Oil<cr>',
        { desc = 'Oil explorer on current buffer directory' },
      },
      {
        '<leader>fO',
        '<cmd>Oil .<cr>',
        { desc = 'Oil explorer on current buffer directory' },
      },
    },
    opts = {
      default_file_explorer = true,
      columns = {
        'icon',
        'size',
      },
      -- Skip the confirmation popup for simple operations
      skip_confirm_for_simple_edits = true,
      keymaps = {
        ['q'] = 'actions.close',
        ['<C-s>'] = false,
      },
      view_options = {
        show_hidden = true,
      },
      -- TODO:(oil config): Configure properly
      -- EXPERIMENTAL support for performing file operations with git
      git = {
        -- Return true to automatically git add/mv/rm files
        add = function(path) return false end,
        mv = function(src_path, dest_path) return false end,
        rm = function(path) return false end,
      },
    },
  },
  -- { 'malewicz1337/oil-git.nvim', dependencies = { 'stevearc/oil.nvim' } },
  -- {
  --   'JezerM/oil-lsp-diagnostics.nvim',
  --   dependencies = { 'stevearc/oil.nvim' },
  -- },
}
