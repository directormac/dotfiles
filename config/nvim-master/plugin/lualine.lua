require('lazyload').on_vim_enter(function()
  vim.pack.add({
    { src = 'https://github.com/nvim-lualine/lualine.nvim' },
  })

  require('lualine').setup({
    options = {
      icons_enabled = true,
      theme = 'auto',
      component_separators = '',
      section_separators = '',
      globalstatus = true,
      disabled_filetypes = { statusline = { 'snacks_dashboard', 'oil' } },

    ,
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch', 'diagnostics' },
      lualine_c = { 'filename' },
      lualine_x = {
        -- stylua: ignore
        {
          function() return require("noice").api.status.command.get() end,
          cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
          color = function() return { fg = "#ff9e64" } end,
        },
        -- stylua: ignore
        {
          function() return require("noice").api.status.mode.get() end,
          cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
          color = function() return { fg = "#ff9e64" } end,
        },
        -- stylua: ignore
        {
          function() return "  " .. require("dap").status() end,
          cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
          color = function() return { fg = "#ff9e64" } end,
        },
      },
      lualine_y = { 'diff', 'encoding', 'fileformat', 'filetype' },
      lualine_z = {
        'lsp_status',
        'progress',
      },
    },
    inactive_sections = {
      -- lualine_a = { 'buffers' },
      -- lualine_b = {},
      -- lualine_c = { 'filename' },
      -- lualine_x = { 'location' },
      -- lualine_y = {},
      -- lualine_z = {},
    },
  })

  vim.opt.showmode = false
end, { sync = true })
