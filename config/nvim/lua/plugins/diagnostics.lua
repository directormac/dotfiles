return {
  {
    'diagnostics',
    event = 'DeferredUIEnter',
    keys = {
      {
        '<leader>cd',
        function()
          local diagnostics = vim.diagnostic.get(0)
          if vim.tbl_isempty(diagnostics) then
            vim.notify('No diagnostics to copy!', vim.log.levels.INFO)
            return
          end
          local lines = {}
          for _, d in ipairs(diagnostics) do
            local msg = string.format(
              '[%s] %s:%d:%d: %s',
              vim.diagnostic.severity[d.severity]:sub(1, 1),
              vim.api.nvim_buf_get_name(0),
              d.lnum + 1,
              d.col + 1,
              d.message:gsub('\n', ' ')
            )
            table.insert(lines, msg)
          end
          local text = table.concat(lines, '\n')
          vim.fn.setreg('+', text)
          vim.notify('Diagnostics copied to clipboard!', vim.log.levels.INFO)
        end,
        desc = 'Copy All Diagnostics',
      },
      -- {
      --   '<leader>e',
      --   function()
      --     vim.diagnostic.open_float(nil, {
      --       border = 'rounded',
      --       scope = 'cursor',
      --       focusable = false,
      --     })
      --   end,
      --   desc = 'Line Diagnostics',
      -- },
    },
    before = function()
      local icons = require('icons').diagnostics

      vim.diagnostic.config({
        virtual_lines = false,
        virtual_text = false,
        underline = {
          severity = {
            min = vim.diagnostic.severity.WARN,
            max = vim.diagnostic.severity.ERROR,
          },
        },
        severity_sort = true,
        float = {
          border = 'rounded',
          source = 'if_many',
          prefix = ' ',
          header = '',
          focusable = false,
        },
        signs = {
          priority = 9999,
          text = {
            [vim.diagnostic.severity.ERROR] = icons.Error or '󰅚',
            [vim.diagnostic.severity.WARN] = icons.Warn or '󰀪',
            [vim.diagnostic.severity.INFO] = icons.Info or '󰋽',
            [vim.diagnostic.severity.HINT] = icons.Hint or '󰌶',
          },
        },
      })

      -- Pop out floating diagnostic on CursorHold (pause on line with issue)
      local diag_group = vim.api.nvim_create_augroup('DiagnosticPopout', { clear = true })
      vim.api.nvim_create_autocmd({ 'CursorHold' }, {
        group = diag_group,
        callback = function()
          local line = vim.api.nvim_win_get_cursor(0)[1] - 1
          local diags = vim.diagnostic.get(0, { lnum = line })
          if #diags > 0 then
            vim.diagnostic.open_float(nil, {
              border = 'rounded',
              scope = 'cursor',
              focusable = false,
              close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
            })
          end
        end,
      })
    end,
  },
}
