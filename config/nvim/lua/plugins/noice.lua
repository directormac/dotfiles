return {
  {
    'nui.nvim',
    load_before = { 'noice.nvim' },
  },
  {
    'noice.nvim',
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
      {
        '<c-f>',
        function()
          if not require('noice.lsp').scroll(4) then return '<c-f>' end
        end,
        silent = true,
        expr = true,
        desc = 'Scroll Forward',
        mode = { 'i', 'n', 's' },
      },
      {
        '<c-b>',
        function()
          if not require('noice.lsp').scroll(-4) then return '<c-b>' end
        end,
        silent = true,
        expr = true,
        desc = 'Scroll Backward',
        mode = { 'i', 'n', 's' },
      },
    },
    opts = {
      notify = {
        enabled = false,
      },
      lsp = {
        progress = {
          enabled = true,
          format = 'lsp_progress',
          format_done = 'lsp_progress_done',
          throttle = 1000 / 30,
          view = 'mini',
        },
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
        },
        hover = {
          enabled = true,
          silent = true,
          opts = {
            border = {
              style = 'single',
            },
            win_options = {
              winblend = 0,
              winhighlight = {
                Normal = 'NormalFloat',
                FloatBorder = 'FloatBorder',
              },
            },
            size = {
              max_width = 80,
              max_height = 30,
            },
          },
        },
        signature = {
          enabled = true,
          auto_open = {
            enabled = false,
            trigger = false,
            luasnip = false,
            throttle = 50,
          },
          opts = {
            border = {
              style = 'single',
            },
            win_options = {
              winblend = 0,
              winhighlight = {
                Normal = 'NormalFloat',
                FloatBorder = 'FloatBorder',
              },
            },
            size = {
              max_width = 80,
              max_height = 20,
            },
          },
        },
        documentation = {
          view = 'hover',
          opts = {
            lang = 'markdown',
            replace = true,
            render = 'plain',
            format = { '{message}' },
            win_options = { concealcursor = 'n', conceallevel = 3 },
          },
        },
      },
      routes = {
        {
          filter = {
            event = 'lsp',
            kind = 'progress',
            any = {
              { find = 'Searching in files' },
              { find = 'WINDOW_PROCESSING_TYPE_DEFINITION' },
              { find = 'Processing reference' },
            },
          },
          opts = { skip = true },
        },
      },
      views = {
        cmdline_popup = {
          border = {
            style = 'single',
          },
          filter_options = {},
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
          border = {
            style = 'single',
          },
        },
      },
      commands = {},
      format = {},
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        -- lsp_doc_border = true,
      },
    },
  },
}
