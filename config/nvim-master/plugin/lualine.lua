local init = function()
  vim.g.lualine_laststatus = vim.o.laststatus
  if vim.fn.argc(-1) > 0 then
    -- set an empty statusline till lualine loads
    vim.o.statusline = ' '
  else
    -- hide the statusline on the starter page
    vim.o.laststatus = 0
  end
end

init()

require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/nvim-lualine/lualine.nvim' },
  })

  local lualine_require = require('lualine_require')
  lualine_require.require = require

  local icons = require('icons')

  vim.o.laststatus = vim.g.lualine_laststatus

  require('lualine').setup({
    options = {
      icons_enabled = true,
      theme = 'auto',
      component_separators = '',
      section_separators = '',
      globalstatus = vim.o.laststatus == 3,
      disabled_filetypes = { statusline = { 'snacks_dashboard', 'oil' } },
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch', 'diagnostics' },
      lualine_c = { 'filename' },
      lualine_x = {
        -- stylua: ignore
        {
          function() return require("noice").api.status.command.get() end,
          cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
          color = function() return { fg = Snacks.util.color("Statement") } end,
        },
        -- stylua: ignore
        {
          function() return require("noice").api.status.mode.get() end,
          cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
          color = function() return { fg = Snacks.util.color("Constant") } end,
        },
        -- stylua: ignore
        {
          function() return "  " .. require("dap").status() end,
          cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
          color = function() return { fg = Snacks.util.color("Debug") } end,
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
end, { sync = true })
