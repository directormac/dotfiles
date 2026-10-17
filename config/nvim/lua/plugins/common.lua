return {
  {
    'mini.nvim',
    lazy = false,
    after = function(plugin)
      require('mini.icons').setup()
      -- require('mini.bracketed').setup()
      --
      -- require('mini.surround').setup({
      --   mappings = {
      --     add = 'zsa',
      --     delete = 'zsd',
      --     find = 'zsf',
      --     find_left = 'zsF',
      --     highlight = 'zsh',
      --     replace = 'zsr',
      --     update_n_lines = 'gsn',
      --   },
      -- })
      --
      -- vim.keymap.set('n', 'zsq', function()
      --   -- Pass an empty target '' with 'i' (inside), which tells mini.surround
      --   -- to automatically detect and target the closest surrounding pair around thome.he cursor.
      --   require('mini.surround').replace('i', '', "'")
      -- end, { desc = 'Replace current surrounding with single quotes' })
    end,
  },
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
  {
    'nvim-web-devicons',
    on_require = { 'nvim-web-devicons' },
    opts = {},
  },
  {
    'plenary.nvim',
    on_require = { 'plenary' },
  },
  {
    'nvim-nio',
    on_require = { 'nio' },
  },
  {
    -- Configuration Reference https://github.com/gbprod/yanky.nvim#%EF%B8%8F-configuration
    'yanky.nvim',
    on_require = { 'yanky' },
  },
  -- https://github.com/ChmaraX/herdr-nvim
  -- { 'herdr-nvim', event = 'DeferredUIEnter', opts = {} },
}
