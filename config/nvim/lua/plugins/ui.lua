-- Web-devicons, which-key, fidget, and vim-startuptime.
return {
  {
    'nvim-web-devicons',
    event = 'DeferredUIEnter',
    after = function(plugin)
      require('nvim-web-devicons').setup()
    end,
  },
  {
    'which-key.nvim',
    event = 'DeferredUIEnter',
    after = function(plugin)
      require('which-key').setup({
        preset = 'helix',
        plugins = {
          marks = true,
          registers = true,
          spelling = {
            enabled = true,
            suggestions = 20,
          },
          presets = {
            operators = true,
            motions = true,
            text_objects = true,
            windows = true,
            nav = true,
            z = true,
            g = true,
          },
        },
        delay = 0,
        icons = { mappings = vim.g.have_nerd_font },
        spec = {
          { '<leader>a', group = 'AI (sidekick)' },
          { '<leader>b', group = 'Buffers' },
          { '<leader>c', group = 'Code Related Actions', mode = { 'n', 'x' } },
          { '<leader>d', group = 'Debug' },
          { '<leader>f', group = 'Find' },
          { '<leader>g', group = 'Git' },
          { '<leader>o', group = 'Other' },
          { '<leader>q', group = 'Quit / Session' },
          { '<leader>s', group = 'Search' },
          { '<leader>sn', group = 'Noice' },
          { '<leader>t', group = 'Tasks' },
          { '<leader>u', group = 'Ui' },
          { '<leader>w', group = 'Windows' },
          { '<leader>x', group = 'Diagnostics / Quickfix' },
          { '<leader><tab>', group = 'Tabs' },
        },
      })

      vim.keymap.set('n', '<leader>?', '<cmd>lua Snacks.picker.keymaps()<CR>', { desc = 'Search Keybindings' })
    end,
  },
  {
    'fidget.nvim',
    event = 'DeferredUIEnter',
    after = function(plugin) require('fidget').setup({}) end,
  },
  {
    'vim-startuptime',
    cmd = { 'StartupTime' },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixInfo(vim.v.progpath, 'progpath')
    end,
  },
}
