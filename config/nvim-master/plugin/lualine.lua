vim.pack.add({ 'https://github.com/nvim-tree/nvim-web-devicons' })
vim.pack.add({ 'https://github.com/nvim-lualine/lualine.nvim' })

local defer_status_line = function()
  vim.g.lualine_laststatus = vim.o.laststatus
  if vim.fn.argc(-1) > 0 then
    -- set an empty statusline till lualine loads
    vim.o.statusline = ' '
  else
    -- hide the statusline on the starter page
    vim.o.laststatus = 0
  end
end

local lualine_require = require('lualine_require')
lualine_require.require = require

vim.o.laststatus = vim.g.lualine_laststatus

require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = '',
    section_separators = '',
    -- globalstatus = vim.o.laststatus == 3,
    globalstatus = '',
    disabled_filetypes = { statusline = { 'snacks_dashboard', 'oil' } },
  },

  -- sections = {
  --   lualine_a = {
  --     function()
  --       local reg = vim.fn.reg_recording()
  --       -- If a macro is being recorded, show "Recording @<register>"
  --       if reg ~= '' then
  --         return 'Recording @' .. reg
  --       else
  --         -- Get the full mode name using nvim_get_mode()
  --         local mode = vim.api.nvim_get_mode().mode
  --         local mode_map = {
  --           n = 'NORMAL',
  --           i = 'INSERT',
  --           v = 'VISUAL',
  --           V = 'V-LINE',
  --           ['^V'] = 'V-BLOCK',
  --           c = 'COMMAND',
  --           R = 'REPLACE',
  --           s = 'SELECT',
  --           S = 'S-LINE',
  --           ['^S'] = 'S-BLOCK',
  --           t = 'TERMINAL',
  --         }
  --
  --         -- Return the full mode name
  --         return mode_map[mode] or mode:upper()
  --       end
  --     end,
  --   },
  --   lualine_b = { 'branch', 'diff', 'diagnostics' },
  --   lualine_x = {
  --     {
  --       require('noice').api.status.mode.get,
  --       cond = require('noice').api.status.mode.has,
  --       color = { fg = '#ff9e64' },
  --     },
  --     -- Formatter status
  --     {
  --       function() return '󰉣' end,
  --       color = function()
  --         local has_conform, conform = pcall(require, 'conform')
  --         if not has_conform then return 'Comment' end
  --         local formatters = conform.list_formatters(0)
  --         if #formatters > 0 then
  --           return nil
  --         else
  --           return 'Comment'
  --         end
  --       end,
  --     },
  --     -- Linter status
  --     {
  --       function() return '󰁨' end,
  --       color = function()
  --         local has_lint, lint = pcall(require, 'lint')
  --         if not has_lint then return 'Comment' end
  --         local linters = lint.linters_by_ft[vim.bo.filetype] or {}
  --         if #linters > 0 then
  --           return nil
  --         else
  --           return 'Comment'
  --         end
  --       end,
  --     },
  --     'encoding',
  --     'fileformat',
  --     'filetype',
  --   },
  -- },
  --
  -- extensions = { 'mason' },

  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    -- lualine_x = { 'lsp_status', 'progress' },
    lualine_x = {
      -- Snacks.profiler.status(),
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
    lualine_y = { 'encoding', 'fileformat', 'filetype' },
    lualine_z = {
      'lsp_status',
      'progress',
      function() return ' ' .. os.date('%R') end,
    },
  },
  -- inactive_sections = {
  --   lualine_a = {},
  --   lualine_b = {},
  --   lualine_c = { 'filename' },
  --   lualine_x = { 'location' },
  --   lualine_y = {},
  --   lualine_z = {},
  -- },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {},
})
