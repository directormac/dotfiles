-- Diagnostic configuration
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
