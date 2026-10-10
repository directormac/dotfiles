-- oil.nvim file explorer, plus the git and diagnostics integrations.
--
-- NOTE: these are lze specs, not lazy.nvim specs. The translation:
--   * `opts = { ... }` -> `after = function() require('<module>').setup({ ... }) end`
--   * `keys = { { lhs, rhs, { desc = ... } } }` -> `keys = { { lhs, rhs, desc = ... } }`
--     (`desc` has to be a named field of the same table, a nested table is dropped)
--   * there is no `pkgs` / `dependencies` field: Nix decides what is installed,
--     and `auto_enable` disables a spec whose plugin is missing
--   * `on_plugin = { 'oil.nvim' }` (not `dep_of`): the integration is configured
--     AFTER oil is loaded, which `dep_of` cannot guarantee since it fires the
--     dependency's `after` hook before the dependent is packadd'd
nixInfo.lze.load({
  {
    'oil.nvim',
    auto_enable = true,
    keys = {
      { '<leader>fo', '<cmd>Oil<cr>', desc = 'Oil explorer on current buffer directory' },
      { '<leader>fO', '<cmd>Oil .<cr>', desc = 'Oil explorer on parent directory' },
    },
    after = function()
      -- icon provider, installed as a startup spec in neovim.nix
      require('oil').setup({
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
        -- EXPERIMENTAL support for performing file operations with git.
        git = {
          -- Return true to automatically git add/mv/rm files
          add = function(path) return false end,
          mv = function(src_path, dest_path) return false end,
          rm = function(path) return false end,
        },
      })
    end,
  },
  {
    -- git status highlights and symbols in oil (malewicz1337/oil-git.nvim)
    'oil-git.nvim',
    auto_enable = true,
    on_plugin = { 'oil.nvim' },
    after = function()
      local git_icons = require('config.icons').git
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
    -- diagnostics in the oil window
    'oil-lsp-diagnostics.nvim',
    auto_enable = true,
    on_plugin = { 'oil.nvim' },
    after = function()
      require('oil-lsp-diagnostics').setup({
        -- jump to diagnostic on cursor hold
        show_diagnostics_on_cursor_hold = true,
      })
    end,
  },
})
