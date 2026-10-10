-- Diagnostic configuration and CursorHold auto-popout.
local icons = require('config.icons').diagnostics

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
    focusable = true,
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

-- Copy all diagnostics keymap
vim.keymap.set('n', '<leader>cd', function()
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
end, { desc = 'Copy All Diagnostics' })

-- Pop out floating diagnostic or LSP hover documentation on CursorHold
local diag_group = vim.api.nvim_create_augroup('CursorHoldPopout', { clear = true })
local last_cursor = nil

vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'BufLeave' }, {
  group = diag_group,
  callback = function() last_cursor = nil end,
})

vim.api.nvim_create_autocmd({ 'CursorHold' }, {
  group = diag_group,
  callback = function()
    if vim.bo.buftype ~= '' or vim.bo.filetype == 'oil' or vim.fn.mode() ~= 'n' then return end

    if vim.fn.pumvisible() ~= 0 then return end
    local current_win = vim.api.nvim_get_current_win()
    local current_win_cfg = vim.api.nvim_win_get_config(current_win)
    if current_win_cfg.relative and current_win_cfg.relative ~= '' then return end

    local bufnr = vim.api.nvim_get_current_buf()
    local pos = vim.api.nvim_win_get_cursor(0)

    local existing_hover = vim.b[bufnr].lsp_floating_preview
    if existing_hover and vim.api.nvim_win_is_valid(existing_hover) then return end
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if win ~= current_win and vim.api.nvim_win_is_valid(win) then
        local cfg = vim.api.nvim_win_get_config(win)
        if cfg.relative and cfg.relative ~= '' then return end
      end
    end

    if last_cursor and last_cursor.bufnr == bufnr and last_cursor.line == pos[1] and last_cursor.col == pos[2] then
      return
    end
    last_cursor = { bufnr = bufnr, line = pos[1], col = pos[2] }

    local line = pos[1] - 1
    local diags = vim.diagnostic.get(0, { lnum = line })
    local diag_opened = false
    if #diags > 0 then
      diag_opened = vim.diagnostic.open_float(nil, {
        border = 'rounded',
        scope = 'cursor',
        focusable = true,
        focus = false,
        close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
      }) ~= nil
    end

    if diag_opened then return end

    local clients = vim.lsp.get_clients({ bufnr = 0, method = 'textDocument/hover' })
    if #clients > 0 then
      vim.lsp.buf.hover({
        border = 'rounded',
        focus = false,
        silent = true,
        focusable = true,
      })
    end
  end,
})
