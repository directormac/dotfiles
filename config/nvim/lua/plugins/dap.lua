return {
  {
    'nvim-dap',
    auto_enable = true,
    keys = {
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle breakpoint' },
      { '<leader>dc', function() require('dap').continue() end, desc = 'Continue' },
      { '<leader>di', function() require('dap').step_into() end, desc = 'Step into' },
      { '<leader>do', function() require('dap').step_over() end, desc = 'Step over' },
      { '<leader>dO', function() require('dap').step_out() end, desc = 'Step out' },
      { '<leader>dq', function() require('dap').terminate() end, desc = 'Terminate' },
      { '<leader>du', function() require('dapui').toggle() end, desc = 'Toggle DAP UI' },
      { '<leader>dLl', function() require('osv').launch({ port = 8086 }) end, desc = 'Debug Lua: launch server' },
      { '<leader>dLr', function() require('osv').run_this() end, desc = 'Debug Lua: run this' },
    },
    after = function()
      local icons = require('icons').dap
      for name, sign in pairs(icons) do
        ---@type string[]
        local parts = type(sign) == 'table' and sign or { sign }
        vim.fn.sign_define('Dap' .. name, {
          text = parts[1],
          texthl = parts[2] or 'DiagnosticInfo',
          linehl = parts[3],
          numhl = parts[3],
        })
      end

      require('nvim-dap-virtual-text').setup({ virt_text_pos = 'eol' })

      local dap = require('dap')
      local dapui = require('dapui')

      dapui.setup()

      dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
      dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
      dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

      -- lua (one-small-step-for-vimkind)
      dap.adapters.nlua = function(callback, config)
        callback({ type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 })
      end

      dap.configurations.lua = {
        {
          type = 'nlua',
          request = 'attach',
          name = 'Attach to running Neovim instance',
        },
      }
    end,
  },
  { 'nvim-dap-ui', auto_enable = true, dep_of = { 'nvim-dap' } },
  { 'nvim-nio', auto_enable = true, dep_of = { 'nvim-dap-ui' } },
  { 'nvim-dap-virtual-text', auto_enable = true, dep_of = { 'nvim-dap' } },
  { 'one-small-step-for-vimkind', auto_enable = true, dep_of = { 'nvim-dap' } },
}
