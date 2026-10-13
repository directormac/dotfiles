local M = {}

--- Deep merge that appends and deduplicates lists, and recurses into dicts.
--- Use vim.NIL as a value to explicitly remove a key.
---@param base table
---@param override table
---@return table
M.merge = function(base, override)
  for k, v in pairs(override) do
    if v == vim.NIL then
      base[k] = nil
    elseif type(v) == 'table' then
      local bv = base[k]
      if type(bv) ~= 'table' then
        base[k] = v
      elseif vim.islist(v) then
        for _, item in ipairs(v) do
          if type(item) == 'table' or not vim.list_contains(bv, item) then table.insert(bv, item) end
        end
      else
        M.merge(bv, v)
      end
    else
      base[k] = v
    end
  end
  return base
end

M.hover_or_focus = function()
  local current_win = vim.api.nvim_get_current_win()
  local win_cfg = vim.api.nvim_win_get_config(current_win)
  if win_cfg.relative and win_cfg.relative ~= '' then
    vim.cmd('wincmd p')
    return
  end

  vim.lsp.buf.hover()
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

--- Resolve symlinks in a path. For paths that do not exist yet (new files),
--- resolves the deepest existing parent and appends the remainder.
---@param path? string
---@return string?
M.realpath = function(path)
  if path == nil or path == '' then return path end
  local real = vim.uv.fs_realpath(path)
  if real then return vim.fs.normalize(real) end
  local dir = vim.fs.dirname(path)
  local base = vim.fs.basename(path)
  local real_dir = vim.uv.fs_realpath(dir)
  if real_dir then return vim.fs.normalize(real_dir .. '/' .. base) end
  return vim.fs.normalize(path)
end

M.root_patterns = { '.git', 'flake.nix', 'package.json', 'Cargo.toml', 'go.mod', 'pyproject.toml' }

--- Per-buffer root cache, invalidated by the autocmds below.
---@type table<number, string>
M._root_cache = {}

local root_group = vim.api.nvim_create_augroup('config_root_cache', { clear = true })
vim.api.nvim_create_autocmd({ 'LspAttach', 'BufWritePost', 'BufEnter', 'BufDelete' }, {
  group = root_group,
  callback = function(event) M._root_cache[event.buf] = nil end,
})
-- cwd fallback makes every buffer's root stale on directory change
vim.api.nvim_create_autocmd('DirChanged', {
  group = root_group,
  callback = function() M._root_cache = {} end,
})

vim.api.nvim_create_user_command('Root', function()
  local root = M.root()
  local cwd = M.cwd()
  local lines = { root }
  if root ~= cwd then lines[#lines + 1] = 'cwd: ' .. cwd end
  vim.notify(table.concat(lines, '\n'), { title = 'Root' })
end, { desc = 'Project root for current buffer' })

---@param opts? { buf?: number, lsp?: boolean, patterns?: string[] }
---@return string
M.root = function(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local cacheable = opts.patterns == nil and opts.lsp == nil
  if cacheable and M._root_cache[buf] then return M._root_cache[buf] end

  local file = vim.api.nvim_buf_get_name(buf)
  local path = file ~= '' and M.realpath(file) or M.cwd()

  local ret

  if package.loaded['snacks'] and Snacks.git and Snacks.git.get_root then
    local git_root = Snacks.git.get_root(path)
    if git_root then ret = M.realpath(git_root) end
  end

  if not ret then
    local detected = vim.fs.root(path, opts.patterns or M.root_patterns)
    if detected then ret = M.realpath(detected) end
  end

  if not ret and opts.lsp ~= false and vim.lsp.get_clients then
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
      local config = client.config
      local ws = config.workspace_folders and config.workspace_folders[1]
      if ws then
        ret = M.realpath(ws.uri and vim.uri_to_fname(ws.uri) or ws.name)
        if ret then break end
      end
      if config.root_dir then
        ret = M.realpath(config.root_dir)
        if ret then break end
      end
    end
  end

  if not ret then ret = M.cwd() end
  if cacheable then M._root_cache[buf] = ret end
  return ret
end

--- Open FFF file picker in cwd or root
---@param opts? table
M.picker_files = function(opts)
  opts = opts or {}
  local target_cwd = opts.cwd or (opts.root and M.root(opts) or M.cwd())
  local picker_opts = vim.tbl_deep_extend('force', opts, { cwd = target_cwd })
  picker_opts.root = nil
  require('fff').find_files(picker_opts)
end

--- Open FFF live grep in cwd or root
---@param opts? table
M.picker_grep = function(opts)
  opts = opts or {}
  local target_cwd = opts.cwd or (opts.root and M.root(opts) or M.cwd())
  local picker_opts = vim.tbl_deep_extend('force', opts, { cwd = target_cwd })
  picker_opts.root = nil
  require('fff').live_grep(picker_opts)
end

-- Lualine helpers, adapted from LazyVim
M.lualine = {}

---@param icon string
---@param status fun(): nil|"ok"|"error"|"pending"
function M.lualine.status(icon, status)
  local colors = {
    ok = 'Special',
    error = 'DiagnosticError',
    pending = 'DiagnosticWarn',
  }
  return {
    function() return icon end,
    cond = function() return status() ~= nil end,
    color = function() return { fg = Snacks.util.color(colors[status()] or colors.ok) } end,
  }
end

---@param component any
---@param text string
---@param hl_group? string
---@return string
function M.lualine.format(component, text, hl_group)
  text = text:gsub('%%', '%%%%')
  if not hl_group or hl_group == '' then return text end
  ---@type table<string, string>
  component.hl_cache = component.hl_cache or {}
  local lualine_hl_group = component.hl_cache[hl_group]
  if not lualine_hl_group then
    local utils = require('lualine.utils.utils')
    ---@type string[]
    local gui = vim.tbl_filter(function(x) return x end, {
      utils.extract_highlight_colors(hl_group, 'bold') and 'bold',
      utils.extract_highlight_colors(hl_group, 'italic') and 'italic',
    })
    lualine_hl_group = component:create_hl({
      fg = utils.extract_highlight_colors(hl_group, 'fg'),
      gui = #gui > 0 and table.concat(gui, ',') or nil,
    }, 'util_' .. hl_group) --[[@as string]]
    component.hl_cache[hl_group] = lualine_hl_group
  end
  return component:format_hl(lualine_hl_group) .. text .. component:get_default_hl()
end

--- Strip prefix from path only when it is followed by a separator,
--- so /a/b never matches /a/bc.
local function strip_prefix(path, prefix)
  if path:find(prefix, 1, true) ~= 1 then return nil end
  local rest = path:sub(#prefix + 1)
  local sep = rest:sub(1, 1)
  if sep ~= '/' and sep ~= '\\' then return nil end
  return rest:sub(2)
end

---@param opts? {relative: "cwd"|"root", modified_hl: string?, directory_hl: string?, filename_hl: string?, modified_sign: string?, readonly_icon: string?, length: number?}
---@return fun(self: any): string
function M.lualine.pretty_path(opts)
  opts = vim.tbl_extend('force', {
    relative = 'cwd',
    modified_hl = 'MatchParen',
    directory_hl = '',
    filename_hl = 'Bold',
    modified_sign = '',
    readonly_icon = ' 󰌾 ',
    length = 3,
  }, opts or {})

  return function(self)
    local path = vim.fn.expand('%:p')
    if path == '' then return '' end

    path = M.realpath(path)
    local root = M.root()
    local cwd = M.cwd()

    local stripped
    if opts.relative == 'cwd' then stripped = strip_prefix(path, cwd) end
    if not stripped then stripped = strip_prefix(path, root) end
    if stripped then path = stripped end

    local sep = package.config:sub(1, 1)
    local parts = vim.split(path, '[\\/]')

    if opts.length > 0 and #parts > opts.length then
      parts = { parts[1], '…', unpack(parts, #parts - opts.length + 2, #parts) }
    end

    if opts.modified_hl and vim.bo.modified then
      parts[#parts] = parts[#parts] .. opts.modified_sign
      parts[#parts] = M.lualine.format(self, parts[#parts], opts.modified_hl)
    else
      parts[#parts] = M.lualine.format(self, parts[#parts], opts.filename_hl)
    end

    local dir = ''
    if #parts > 1 then
      dir = table.concat({ unpack(parts, 1, #parts - 1) }, sep)
      dir = M.lualine.format(self, dir .. sep, opts.directory_hl)
    end

    local readonly = ''
    if vim.bo.readonly then readonly = M.lualine.format(self, opts.readonly_icon, opts.modified_hl) end
    return dir .. parts[#parts] .. readonly
  end
end

---@param opts? {cwd: boolean, subdirectory: boolean, parent: boolean, other: boolean, icon?: string, color?: fun(): table}
---@return table
function M.lualine.root_dir(opts)
  opts = vim.tbl_extend('force', {
    cwd = false,
    subdirectory = true,
    parent = true,
    other = true,
    icon = '󱉭',
    color = function() return { fg = Snacks.util.color('Special') } end,
  }, opts or {})

  local function get()
    local cwd = M.cwd()
    local root = M.root()
    local name = vim.fs.basename(root)
    if root == cwd then
      return opts.cwd and name
    elseif root:find(cwd, 1, true) == 1 then
      return opts.subdirectory and name
    elseif cwd:find(root, 1, true) == 1 then
      return opts.parent and name
    else
      return opts.other and name
    end
  end

  return {
    function()
      local name = get()
      if not name then return '' end
      return (opts.icon and opts.icon .. ' ') .. name
    end,
    cond = function() return type(get()) == 'string' end,
    color = opts.color,
  }
end

_G.Util = M
return M
