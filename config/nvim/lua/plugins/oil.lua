return {
  {
    'oil.nvim',
    cmd = { 'Oil' },
    keys = {
      { '<leader>fo', '<cmd>Oil<cr>', desc = 'Oil explorer on current buffer directory' },
      { '<leader>fO', '<cmd>Oil .<cr>', desc = 'Oil explorer on root directory' },
    },
    -- Configuration Reference https://github.com/stevearc/oil.nvim#options
    ---@type oil.SetupOpts
    opts = {
      -- Set to true to watch the filesystem for changes and reload oil
      watch_for_changes = true,
      default_file_explorer = true,
      columns = {
        'icon',
        'size',
      },
      skip_confirm_for_simple_edits = true,
      keymaps = {
        ['q'] = 'actions.close',
        ['<C-s>'] = false,
      },
      view_options = {
        show_hidden = true,
      },
      git = {
        add = function(path) return false end,
        mv = function(src_path, dest_path) return false end,
        rm = function(path) return false end,
      },
    },
    after = function(plugin) require('oil').setup(plugin.opts or {}) end,
  },
  {
    'oil-git.nvim',
    load_before = { 'oil.nvim' },
    after = function()
      local git_icons = Icons.git
      local symbols = {
        added = git_icons.added,
        modified = git_icons.modified,
        renamed = git_icons.renamed,
        deleted = git_icons.deleted or git_icons.removed,
        copied = git_icons.copied,
        conflict = git_icons.conflict,
        untracked = git_icons.untracked,
        ignored = git_icons.ignored,
      }

      require('oil-git').setup({
        show_file_highlights = true,
        show_directory_highlights = true,
        show_file_symbols = true,
        show_directory_symbols = true,
        show_branch = false,
        branch_format = (git_icons.branch or ' ') .. '%s',
        symbols = {
          file = symbols,
          directory = symbols,
        },
      })
    end,
  },
  {
    'oil-lsp-diagnostics.nvim',
    load_before = { 'oil.nvim' },
    after = function()
      require('oil-lsp-diagnostics').setup({
        show_diagnostics_on_cursor_hold = true,
      })
    end,
  },
}
