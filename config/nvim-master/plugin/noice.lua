-- vim.pack.add({ 'https://github.com/MunifTanjim/nui.nvim' })
-- vim.pack.add({
--   'https://github.com/folke/noice.nvim',
-- })
--
-- vim.pack.add({
--   'https://github.com/rcarriga/nvim-notify',
-- })

-- Reference https://github.com/folke/noice.nvim#%EF%B8%8F-configuration
-- nvim-notify https://github.com/rcarriga/nvim-notify

require('noice').setup({
  cmdline = {
    view = 'cmdline',
  },
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = false,
      ['vim.lsp.util.stylize_markdown'] = false,
      ['cmp.entry.get_documentation'] = false,
    },
  },
  routes = {
    {
      filter = {
        event = 'msg_showmode',
      },
      view = 'notify',
    },
    {
      filter = {
        event = 'msg_show',
        any = {
          { find = '%d+L, %d+B' },
          { find = '; after #%d+' },
          { find = '; before #%d+' },
        },
      },
      view = 'mini',
    },
  },
  -- views = {
  --   cmdline_popup = {
  --     position = {
  --       row = 5,
  --       col = '50%',
  --     },
  --     size = {
  --       width = 60,
  --       height = 'auto',
  --     },
  --   },
  --   popupmenu = {
  --     relative = 'editor',
  --     position = {
  --       row = 8,
  --       col = '50%',
  --     },
  --     size = {
  --       width = 60,
  --       height = 10,
  --     },
  --     border = {
  --       style = 'rounded',
  --       padding = { 0, 1 },
  --     },
  --     win_options = {
  --       winhighlight = { Normal = 'Normal', FloatBorder = 'DiagnosticInfo' },
  --     },
  --   },
  -- },

  presets = {
    bottom_search = false,
    command_palette = true,
    long_message_to_split = true,
  },
})

vim.keymap.set({ 'n' }, '<leader>sn', '', { desc = '+noice' })
vim.keymap.set(
  'c',
  '<S-Enter>',
  function() require('noice').redirect(vim.fn.getcmdline()) end,
  { desc = 'Redirect Cmdline' }
)
vim.keymap.set('n', '<leader>snl', function() require('noice').cmd('last') end, { desc = 'Noice Last Message' })
vim.keymap.set('n', '<leader>snh', function() require('noice').cmd('history') end, { desc = 'Noice History' })
vim.keymap.set('n', '<leader>sna', function() require('noice').cmd('all') end, { desc = 'Noice All' })
vim.keymap.set('n', '<leader>snd', function() require('noice').cmd('dismiss') end, { desc = 'Dismiss All' })
vim.keymap.set('n', '<leader>snt', function() require('noice').cmd('pick') end, { desc = 'Noice Picker' })
vim.keymap.set({ 'i', 'n', 's' }, '<c-f>', function() end, { silent = true, expr = true, desc = 'Scroll Forward' })
vim.keymap.set({ 'i', 'n', 's' }, '<c-b>', function()
  if not require('noice.lsp').scroll(-4) then return '<c-b>' end
end, { silent = true, expr = true, desc = 'Scroll Backward' })
