return {
  'snacks.nvim',
  keys = {

    { ']]', function() Snacks.words.jump(vim.v.count1) end, desc = 'Next Reference' },
    { '[[', function() Snacks.words.jump(-vim.v.count1) end, desc = 'Prev Reference' },
  },
  opts = {
    words = {
      enable = true,
    },
  },
}
