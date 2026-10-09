-- Statusline, which-key, notifications, startup profiling and git signs.
return {
  {
    'nvim-web-devicons',
    auto_enable = true,
    event = 'DeferredUIEnter',
    after = function(plugin)
      -- Setup nvim-web-devicons
      require('nvim-web-devicons').setup()
    end,
  },
  {
    'which-key.nvim',
    auto_enable = true,
    -- cmd = { "" },
    event = 'DeferredUIEnter',
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      ---@type wk.Opts
      require('which-key').setup({
        preset = 'helix',
        plugins = {
          marks = true, -- shows a list of your marks on ' and `
          registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
          spelling = {
            enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            suggestions = 20, -- how many suggestions should be shown in the list?
          },
          -- the presets plugin, adds help for a bunch of default keybindings in Neovim
          -- No actual key bindings are created
          presets = {
            operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
            motions = true, -- adds help for motions
            text_objects = true, -- help for text objects triggered after entering an operator
            windows = true, -- default bindings on <c-w>
            nav = true, -- misc bindings to work with windows
            z = true, -- bindings for folds, spelling and others prefixed with z
            g = true, -- bindings for prefixed with g
          },
        },
        delay = 0,
        icons = { mappings = vim.g.have_nerd_font },
        spec = {
          { '<leader>c', group = 'Code Related Actions', mode = { 'n', 'x' } },
          { '<leader>d', group = 'Debug' },
          -- { '<leader>dg', group = 'Debug' },
          -- { '<leader>du', group = 'Debug Ui' },
          { '<leader>g', group = 'Git' },
          { '<leader>n', group = 'Next' },
          { '<leader>p', group = 'Previous' },
          { '<leader>r', group = 'Refactor' },
          { '<leader>s', group = 'Search' },
          { '<leader>w', group = 'Workspace' },
          { '<leader>f', group = 'Find' },
          { '<leader>t', group = 'Toggle' },
          { '<leader>o', group = 'Other' },
          { '<leader>u', group = 'Ui' },
          { '<leader>b', group = 'Buffers' },
          { '<leader>l', group = 'Logs' },
        },
      })
    end,
  },
  {
    'fidget.nvim',
    auto_enable = true,
    event = 'DeferredUIEnter',
    -- keys = "",
    after = function(plugin) require('fidget').setup({}) end,
  },
  {
    'vim-startuptime',
    auto_enable = true,
    cmd = { 'StartupTime' },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixInfo(vim.v.progpath, 'progpath')
    end,
  },
}
