vim.pack.add({ 'https://github.com/folke/edgy.nvim' })

-- Reference: https://github.com/folke/edgy.nvim#%EF%B8%8F-configuration

require('edgy').setup({
  options = {
    left = { size = 30 },
    bottom = { size = 10 },
    right = { size = 30 },
    top = { size = 10 },
  },
  animate = {
    enabled = false,
  },
  -- enable this to exit Neovim when only edgy windows are left
  exit_when_last = false,
  -- close edgy when all windows are hidden instead of opening one of them
  -- disable to always keep at least one edgy split visible in each open section
  close_when_all_hidden = true,

  left = {}, ---@type (Edgy.View.Opts|string)[]
  right = {}, ---@type (Edgy.View.Opts|string)[]
  top = {}, ---@type (Edgy.View.Opts|string)[]
  ---@type (Edgy.View.Opts|string)[]
  bottom = {
    {
      ft = 'noice',
      size = { height = 0.4 },
      filter = function(buf, win)
        return vim.api.nvim_win_get_config(win).relative == ''
      end,
    },
    {
      ft = 'help',
      size = { height = 20 },
      -- only show help buffers
      filter = function(buf) return vim.bo[buf].buftype == 'help' end,
    },
    { ft = 'qf', title = 'QuickFix' },
    { title = 'Grug Far', ft = 'grug-far' },
    {
      ft = 'snacks_terminal',
      size = { height = 0.4 },
      title = '%{b:snacks_terminal.id}: %{b:term_title}',
      filter = function(_buf, win)
        return vim.w[win].snacks_win
          and vim.w[win].snacks_win.position == pos
          and vim.w[win].snacks_win.relative == 'editor'
          and not vim.w[win].trouble_preview
      end,
    },
  },
})
