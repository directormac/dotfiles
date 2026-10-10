return {
  'fff.nvim',
  cmd = { 'FFFFind', 'FFFScan', 'FFFResume', 'FFFLiveGrep' },
  keys = {
    {
      '<leader>fw',
      function() require('fff').live_grep_under_cursor() end,
      mode = { 'n', 'x' },
      desc = 'Search current word / selection',
    },
  },
  after = function()
    require('fff').setup({
      prompt = ' ',
    })
  end,
}
