local M = {}

M.hover_or_focus = function()
  local current_win = vim.api.nvim_get_current_win()
  local win_cfg = vim.api.nvim_win_get_config(current_win)
  if win_cfg.relative and win_cfg.relative ~= '' then
    vim.cmd('wincmd p')
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local hover_win = vim.b[bufnr].lsp_floating_preview
  if hover_win and vim.api.nvim_win_is_valid(hover_win) then
    vim.api.nvim_set_current_win(hover_win)
    return
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= current_win and vim.api.nvim_win_is_valid(win) then
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative and cfg.relative ~= '' and cfg.focusable ~= false then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  end

  vim.lsp.buf.hover({ border = 'rounded', focus = true, silent = true })
end

M.buf_delete = function(buf)
  if package.loaded['snacks'] and Snacks.bufdelete then
    Snacks.bufdelete(buf)
  else
    vim.cmd('bdelete ' .. (buf and tostring(buf) or ''))
  end
end

return M
