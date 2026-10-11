return {
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
      -- {
      --   '<c-f>',
      --   function()
      --     if not require('noice.lsp').scroll(4) then return '<c-f>' end
      --   end,
      --   silent = true,
      --   expr = true,
      --   desc = 'Scroll Forward',
      --   mode = { 'i', 'n', 's' },
      -- },
      -- {
      --   '<c-b>',
      --   function()
      --     if not require('noice.lsp').scroll(-4) then return '<c-b>' end
      --   end,
      --   silent = true,
      --   expr = true,
      --   desc = 'Scroll Backward',
      --   mode = { 'i', 'n', 's' },
      -- },
    },
    before = function() require('lz.n').trigger_load({ 'nui.nvim', 'nvim-notify' }) end,
    after = function()
      if vim.o.filetype == 'lazy' then vim.cmd([[messages clear]]) end

      require('noice').setup({
        -- popupmenu = {
        --   enabled = false, -- Blink.cmp manages all completion menus!
        -- },
        lsp = {

          progress = {
            enabled = false,
            -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
            -- See the section on formatting for more details on how to customize.
            --- @type NoiceFormat|string
            format = 'lsp_progress',
            --- @type NoiceFormat|string
            format_done = 'lsp_progress_done',
            throttle = 1000 / 30, -- frequency to update lsp progress message
            view = 'mini',
          },

          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
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
              enabled = true,
              trigger = true,
              luasnip = true,
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
              event = 'lsp',
              kind = 'progress',
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
  { 'nui.nvim', lazy = true },
  -- {
  --   'nvim-notify',
  --   lazy = true,
  --   after = function()
  --     require('notify').setup({
  --       background_colour = '#000000',
  --     })
  --   end,
  -- },
}
