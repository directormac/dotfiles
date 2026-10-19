return {
  {
    'edgy.nvim',
    event = 'DeferredUIEnter',
    ---@type Edgy.Config
    opts = {
      options = {
        left = { size = 30 },
        bottom = { size = 10 },
        right = { size = 30 },
        top = { size = 10 },
      },
      animate = { enabled = false },
      exit_when_last = false,
      close_when_all_hidden = true,
      left = {
        {
          title = function() return 'File Explorer' end,
          ft = 'snacks_picker_list',
          size = { width = 0.4 },
          filter = function(buf, win)
            return vim.bo[buf].buftype == 'nofile'
              and vim.bo[buf].filetype == 'snacks_picker_list'
              and vim.api.nvim_win_get_config(win).relative == ''
          end,
        },
      },
      right = {},
      top = {},
      bottom = {
        {
          ft = 'noice',
          size = { height = 0.4 },
          filter = function(buf, win) return vim.api.nvim_win_get_config(win).relative == '' end,
        },
        {
          ft = 'help',
          size = { height = 20 },
          filter = function(buf) return vim.bo[buf].buftype == 'help' end,
        },
        {
          title = function() return 'Grug Far' end,
          ft = 'grug-far',
          size = { height = 0.3 },
        },
        { ft = 'qf', title = function() return 'QuickFix' end },
        {
          ft = 'snacks_terminal',
          size = { height = 0.4 },
          title = function() return '%{b:snacks_terminal.id}: %{b:term_title}' end,
          filter = function(_buf, win)
            return vim.w[win].snacks_win
              and vim.w[win].snacks_win.position ~= 'float'
              and not vim.w[win].trouble_preview
          end,
        },
      },
    },
  },
}
