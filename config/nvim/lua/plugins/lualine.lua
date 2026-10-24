return {
  {
    'lualine.nvim',
    event = 'DeferredUIEnter',
    on_require = { 'lualine' },
    opts = function()
      local icons = Utils.icons
      local util = Utils

      return {
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = '',
          section_separators = '',
          globalstatus = true,
          disabled_filetypes = { statusline = { 'snacks_dashboard', 'oil' } },
        },
        sections = {
          lualine_a = {
            {
              'mode',
              fmt = function()
                -- return "  "
                return '  '
              end,
            },
          },
          lualine_b = { 'branch', 'harpoon2' },
          lualine_c = {
            {
              'diagnostics',
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            { 'filetype', icon_only = true, separator = '', padding = { left = 1, right = 0 } },
            { util.lualine.pretty_path() },
          },
          lualine_x = {
            Snacks.profiler.status(),
            -- Copilot indicator
            {
              function() return ' ' end,
              cond = function()
                local clients = vim.lsp.get_clients({ bufnr = 0, name = 'copilot' })
                if #clients == 0 then return false end
                return _G.CopilotState == nil or _G.CopilotState.has_quota ~= false
              end,
              color = function() return { fg = Snacks.util.color('Special') } end,
            },
            -- Wakatime today summary
            -- stylua: ignore
            -- {
            --   function() return require('wakatime').statusline() end,
            --   cond = function() 
            --     return package.loaded['wakatime'] and require('wakatime').statusline() ~= '' 
            --   end,
            --   icon = '󱑎',
            --   color = function() 
            --     return { fg = Snacks.util.color('Special') } 
            --   end,
            --   __wakatime_statusline = true,
            -- },
            -- stylua: ignore
            {
              function() 
                  return require('noice').api.status.command.get() 
                end,
              cond = function() 
                return package.loaded['noice'] and require('noice').api.status.command.has() 
              end,
              color = function() 
                return { fg = Snacks.util.color('Statement') } 
              end,
            },
            -- stylua: ignore
            {
              function() 
                  return require('noice').api.status.mode.get() 
                end,
              cond = function() 
                return package.loaded['noice'] and require('noice').api.status.mode.has() 
              end,
              color = function() 
                return { fg = Snacks.util.color('Constant') } 
              end,
            },
            -- stylua: ignore
            {
              function() 
                  return '  ' .. require('dap').status() 
                end,
              cond = function() 
                return package.loaded['dap'] and require('dap').status() ~= '' 
              end,
              color = function() 
                return { fg = Snacks.util.color('Debug') } 
              end,
            },
          },
          lualine_y = {
            {
              'diff',
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end,
            },
            { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
            { 'location', padding = { left = 0, right = 1 } },
            -- 'lsp_status',
          },
          lualine_z = {},
        },
      }
    end,
    after = function()
      vim.opt.showmode = false

      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufAdd', 'BufDelete' }, {
        callback = function()
          vim.schedule(function()
            local bufs = vim.fn.getbufinfo({ buflisted = 1 })
            local tabs = vim.fn.gettabinfo()
            vim.o.showtabline = (#bufs > 1 or #tabs > 1) and 2 or 0
          end)
        end,
      })
    end,
  },
}
