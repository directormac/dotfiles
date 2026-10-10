return {
  'grug-far.nvim',
  cmd = { 'GrugFar' },
  keys = {
    {
      '<leader>sr',
      function()
        local grug = require('grug-far')
        local ext = vim.bo.buftype == '' and vim.fn.expand('%:e')
        grug.open({
          transient = true,
          prefills = {
            filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
          },
        })
      end,
      desc = 'Search and Replace',
      mode = { 'n', 'x' },
    },
  },
  after = function()
    require('grug-far').setup({
      engine = 'ripgrep',
    })
  end,
}
