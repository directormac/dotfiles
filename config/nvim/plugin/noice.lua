nixInfo.lze.load({
  {
    'noice.nvim',
    auto_enable = true,
    event = 'DeferredUIEnter',
    keys = {
      { '<leader>sn', '', desc = '+noice' },
      {
        '<S-Enter>',
        mode = 'c',
        function() require('noice').redirect(vim.fn.getcmdline()) end,
        desc = 'Redirect Cmdline',
      },
      { '<leader>snl', function() require('noice').cmd('last') end, desc = 'Noice Last Message' },
      { '<leader>snh', function() require('noice').cmd('history') end, desc = 'Noice History' },
      { '<leader>sna', function() require('noice').cmd('all') end, desc = 'Noice All' },
      { '<leader>snd', function() require('noice').cmd('dismiss') end, desc = 'Dismiss All' },
      { '<leader>snt', function() require('noice').cmd('pick') end, desc = 'Noice Picker' },
    },
    after = function()
      -- HACK: noice shows messages from before it was enabled,
      -- but this is not ideal when Lazy is installing plugins,
      -- so clear the messages in this case.
      if vim.o.filetype == 'lazy' then vim.cmd([[messages clear]]) end

      require('noice').setup({
        lsp = {
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
          },
        },
        routes = {
          {
            filter = {
              any = {
                { find = 'No information available' },
                { find = 'Empty hover response' },
              },
            },
            opts = { skip = true },
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
          {
            filter = {
              event = 'msg_showmode',
            },
            view = 'notify',
          },
        },
        views = {
          cmdline_popup = {
            position = {
              row = 5,
              col = '50%',
            },
            size = {
              width = 60,
              height = 'auto',
            },
          },
          popupmenu = {
            relative = 'editor',
            position = {
              row = 8,
              col = '50%',
            },
            size = {
              width = 60,
              height = 10,
            },
            border = {
              style = 'rounded',
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = { Normal = 'Normal', FloatBorder = 'DiagnosticInfo' },
            },
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
      })
    end,
  },
  { 'nui.nvim', auto_enable = true, dep_of = { 'noice.nvim' } },
  { 'nvim-notify', auto_enable = true, dep_of = { 'noice.nvim' } },
})
