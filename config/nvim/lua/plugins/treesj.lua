return {
  'treesj',
  cmd = { 'TSJToggle' },
  keys = { { '<leader>ct', ':TSJToggle<CR>', desc = 'treesj split/join' } },
  after = function() require('treesj').setup({}) end,
}
