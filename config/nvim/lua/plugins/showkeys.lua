return {
  'showkeys',
  cmd = { 'ShowkeysToggle' },
  keys = {
    { '<leader>uk', '<cmd>ShowkeysToggle<CR>', desc = 'Toggle showkeys', silent = true },
  },
  after = function()
    require('showkeys').setup({
      winhl = 'FloatBorder:Comment,Normal:Normal',
      timeout = 4,
      maxkeys = 5,
      position = 'bottom-center',
    })
  end,
}
