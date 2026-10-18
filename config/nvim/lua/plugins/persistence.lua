return {
  'persistence.nvim',
  event = 'BufReadPre',
  on_require = { 'persistence' },
  keys = {

    { '<leader>qs', function() require('persistence').load() end, desc = 'Restore Session' },

    { '<leader>qS', function() require('persistence').select() end, desc = 'Select and load a session.' },
    {
      '<leader>ql',
      function() require('persistence').load({ last = true }) end,
      desc = 'Restore Last Session',
    },

    { '<leader>qd', function() require('persistence').stop() end, desc = "Don't Save Current Session" },
  },
  before = function()
    -- Session options: include globals so bufferline pinned buffers persist across sessions
    vim.opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }
  end,
  opts = {},
}
