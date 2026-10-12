return {
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
        { 'gs', group = 'Surround', mode = { 'n', 'x' } },
      },
    })

    vim.keymap.set('n', '<leader>?', '<cmd>lua Snacks.picker.keymaps()<CR>', { desc = 'Search Keybindings' })
  end,
}
