return {
  {
    'blink.pairs',
    event = { 'BufReadPost', 'BufNewFile', 'InsertEnter' },
    after = function()
      -- https://github.com/saghen/blink.pairs#installation
      require('blink.pairs').setup({})
    end,
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
