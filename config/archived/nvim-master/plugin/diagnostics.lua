require('lazyload').on_vim_enter(function()
  -- Reference https://github.com/fredrikaverpil/dotfiles/tree/main/nvim-fredrik
  -- native diagnostics
  do
    local icons = require('icons').diagnostics

    vim.diagnostic.config({
      -- Show more details immediately for errors on the current line
      virtual_lines = false,
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = {
        severity = {
          min = vim.diagnostic.severity.WARN,
          max = vim.diagnostic.severity.ERROR,
        },
      },
      virtual_text = {
        current_line = true,
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic) return diagnostic.message end,
      },
      signs = {
        priority = 9999,
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚', -- Error icon
          [vim.diagnostic.severity.WARN] = '󰀪', -- Warning icon
          [vim.diagnostic.severity.INFO] = '󰋽', -- Info icon
          [vim.diagnostic.severity.HINT] = '󰌶', -- Hint icon
        },
      },
      jump = {
        on_jump = function(_, bufnr)
          vim.diagnostic.open_float({
            bufnr = bufnr,
            scope = 'cursor',
            focus = false,
          })
        end,
      },
    })
  end

  -- Function to copy all diagnostics to the clipboard
  local function copy_all_diagnostics()
    local diagnostics = vim.diagnostic.get(nil) -- get all diagnostics in current buffer
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
    vim.fn.setreg('+', text) -- copy to system clipboard
    vim.notify('Diagnostics copied to clipboard!', vim.log.levels.INFO)
  end

  -- Keymap: <leader>cd to copy all diagnostics
  vim.keymap.set('n', '<leader>cd', copy_all_diagnostics, { desc = 'Copy All Diagnostics' })

  -- vim.keymap.set('n', '<leader>ud', function()
  --   vim.diagnostic.enable(not vim.diagnostic.is_enabled())
  --   vim.notify('Diagnostics: ' .. (vim.diagnostic.is_enabled() and 'on' or 'off'))
  -- end, { desc = 'Toggle diagnostics', silent = true })

  -- -- tiny-inline-diagnostic
  do
    vim.pack.add({
      { src = 'https://github.com/rachartier/tiny-inline-diagnostic.nvim' },
    })

    require('tiny-inline-diagnostic').setup({
      options = {
        transparent_cursorline = true,
        show_all_diags_on_cursorline = true,
        multilines = {
          enabled = true,
          always_show = true,
        },
        show_source = {
          enabled = true,
        },
        signs = {
          left = '',
          right = '',
          diag = '●',
          arrow = '    ',
          up_arrow = '    ',
          vertical = ' │',
          vertical_end = ' └',
        },
        blend = {
          factor = 0.22,
        },
        -- Default {"LspAttach"} skips buffers without an LSP (e.g. .proto
        -- files linted only via nvim-lint). DiagnosticChanged attaches the
        -- moment any source produces results, regardless of LSP presence.
        -- See https://github.com/rachartier/tiny-inline-diagnostic.nvim/issues/40
        overwrite_events = { 'DiagnosticChanged' },
      },
      -- preset = '',
    })
  end
end)

-- {
--   "folke/trouble.nvim",
--   cmd = { "Trouble" },
--   opts = {
--     modes = {
--       lsp = {
--         win = { position = "right" },
--       },
--     },
--   },
--   keys = {
--     { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
--     { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
--     { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
--     { "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
--     { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
--     { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
--     {
--       "[q",
--       function()
--         if require("trouble").is_open() then
--           require("trouble").prev({ skip_groups = true, jump = true })
--         else
--           local ok, err = pcall(vim.cmd.cprev)
--           if not ok then
--             vim.notify(err, vim.log.levels.ERROR)
--           end
--         end
--       end,
--       desc = "Previous Trouble/Quickfix Item",
--     },
--     {
--       "]q",
--       function()
--         if require("trouble").is_open() then
--           require("trouble").next({ skip_groups = true, jump = true })
--         else
--           local ok, err = pcall(vim.cmd.cnext)
--           if not ok then
--             vim.notify(err, vim.log.levels.ERROR)
--           end
--         end
--       end,
--       desc = "Next Trouble/Quickfix Item",
--     },
--   },
-- },
