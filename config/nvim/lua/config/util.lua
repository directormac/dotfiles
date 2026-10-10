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

  vim.lsp.buf.hover({ border = 'single', max_height = 40, max_width = 60, focus = true, silent = true })
end

M.buf_delete = function(buf)
  if package.loaded['snacks'] and Snacks.bufdelete then
    Snacks.bufdelete(buf)
  else
    vim.cmd('bdelete ' .. (buf and tostring(buf) or ''))
  end
end

--- Get current working directory normalized
---@return string
M.cwd = function() return vim.fs.normalize(vim.uv.cwd() or vim.fn.getcwd()) end

M.root_patterns = { '.git', 'flake.nix', 'package.json', 'Cargo.toml', 'go.mod', 'pyproject.toml' }

--- Get project root directory
--- Hierarchy:
--- 1. LSP client workspace folders / root_dir (if attached and not opts.lsp == false)
--- 2. Snacks.git.get_root (if snacks loaded)
--- 3. Native root marker search via vim.fs.root
--- 4. Fallback to M.cwd()
---@param opts? { buf?: number, lsp?: boolean, patterns?: string[] }
---@return string
M.root = function(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  local path = (file ~= '' and file) or M.cwd()

  -- 1. LSP root if client attached
  if opts.lsp ~= false and vim.lsp.get_clients then
    local clients = vim.lsp.get_clients({ bufnr = buf })
    for _, client in ipairs(clients) do
      if client.config and client.config.workspace_folders and client.config.workspace_folders[1] then
        return vim.fs.normalize(client.config.workspace_folders[1].name)
      end
      if client.config and client.config.root_dir then return vim.fs.normalize(client.config.root_dir) end
    end
  end

  -- 2. Git root via Snacks
  if package.loaded['snacks'] and Snacks.git and Snacks.git.get_root then
    local git_root = Snacks.git.get_root(path)
    if git_root then return vim.fs.normalize(git_root) end
  end

  -- 3. Native root marker search (Neovim 0.10+)
  local patterns = opts.patterns or M.root_patterns
  local detected = vim.fs.root(path, patterns)
  if detected then return vim.fs.normalize(detected) end

  -- 4. Fallback to CWD
  return M.cwd()
end

--- Open Snacks file picker in cwd or root
---@param opts? table
M.picker_files = function(opts)
  opts = opts or {}
  local target_cwd = opts.cwd or (opts.root and M.root(opts) or M.cwd())
  local picker_opts = vim.tbl_deep_extend('force', {
    cwd = target_cwd,
    layout = { hidden = { 'preview' } },
  }, opts)
  picker_opts.root = nil
  Snacks.picker.files(picker_opts)
end

--- Open Snacks grep in cwd or root
---@param opts? table
M.picker_grep = function(opts)
  opts = opts or {}
  local target_cwd = opts.cwd or (opts.root and M.root(opts) or M.cwd())
  local picker_opts = vim.tbl_deep_extend('force', {
    cwd = target_cwd,
  }, opts)
  picker_opts.root = nil
  Snacks.picker.grep(picker_opts)
end

return M
