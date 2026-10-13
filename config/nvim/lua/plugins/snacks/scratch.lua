return {
  'snacks.nvim',
  keys = {
    { '<leader>.', function() Snacks.scratch() end, desc = 'Toggle Scratch Buffer' },
    { '<leader>S', function() Snacks.scratch.select() end, desc = 'Select Scratch Buffer' },
    { '<leader>s.', function() Snacks.scratch.select() end, desc = 'Select Scratch Buffer' },
  },
  opts = {
    scratch = {
      enable = true,
    },
  },
}
