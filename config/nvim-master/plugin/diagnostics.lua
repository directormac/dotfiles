require('lazyload').on_vim_enter(function()
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

  -- -- tiny-inline-diagnostic
  -- do
  --   vim.pack.add({
  --     { src = 'https://github.com/rachartier/tiny-inline-diagnostic.nvim' },
  --   })
  --
  --   require('tiny-inline-diagnostic').setup({
  --     options = {
  --       show_all_diags_on_cursorline = true,
  --       multilines = {
  --         enabled = true,
  --         always_show = true,
  --       },
  --       show_source = {
  --         enabled = true,
  --       },
  --       -- Default {"LspAttach"} skips buffers without an LSP (e.g. .proto
  --       -- files linted only via nvim-lint). DiagnosticChanged attaches the
  --       -- moment any source produces results, regardless of LSP presence.
  --       -- See https://github.com/rachartier/tiny-inline-diagnostic.nvim/issues/40
  --       overwrite_events = { 'DiagnosticChanged' },
  --     },
  --   })
  -- end

  vim.keymap.set('n', '<leader>ud', function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
    vim.notify('Diagnostics: ' .. (vim.diagnostic.is_enabled() and 'on' or 'off'))
  end, { desc = 'Toggle diagnostics', silent = true })
end)
