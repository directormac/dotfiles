return {
  'lualine.nvim',
  event = 'DeferredUIEnter',
  after = function()
    local icons = require('config.icons')

    require('lualine').setup({
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = '',
        section_separators = '',
        globalstatus = true,
        disabled_filetypes = { statusline = { 'snacks_dashboard', 'oil' } },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch' },
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
          'filename',
        },
        lualine_x = {
          Snacks.profiler.status(),
          {
            function() return require('noice').api.status.command.get() end,
            cond = function() return package.loaded['noice'] and require('noice').api.status.command.has() end,
            color = function() return { fg = Snacks.util.color('Statement') } end,
          },
          {
            function() return require('noice').api.status.mode.get() end,
            cond = function() return package.loaded['noice'] and require('noice').api.status.mode.has() end,
            color = function() return { fg = Snacks.util.color('Constant') } end,
          },
          {
            function() return '  ' .. require('dap').status() end,
            cond = function() return package.loaded['dap'] and require('dap').status() ~= '' end,
            color = function() return { fg = Snacks.util.color('Debug') } end,
          },
        },
        lualine_y = { 'diff', 'location' },
        lualine_z = {
          'lsp_status',
          'progress',
        },
      },
    })

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
}
