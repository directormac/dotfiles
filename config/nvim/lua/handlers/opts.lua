---@type lze.Handler
---Custom `opts` handler for `lze`.
---Provides LazyVim-style automatic `.setup(opts)` execution:
---  1. Resolves `opts` (static table, function(plugin) -> table, or `true` for `{}`).
---  2. Heuristically discovers the plugin's entrypoint module name using common naming conventions:
---     (e.g., "gitsigns.nvim" -> "gitsigns", "nvim-treesitter" -> "nvim-treesitter", "harpoon2" -> "harpoon").
---  3. Automatically calls `require(mod).setup(opts)` before running any user-provided `after` hook.
---  4. Respects `plugin.setup = false` to opt out of automatic setup calls.
local M = {
  spec_field = 'opts',
  set_lazy = false,
}

---Resolve opts from table, function, or boolean shorthand
---@param opts any
---@param plugin lze.Plugin
---@return table|nil
local function resolve_opts(opts, plugin)
  if type(opts) == 'function' then
    return opts(plugin) or {}
  elseif type(opts) == 'table' then
    return opts
  elseif opts == true then
    return {}
  end
  return nil
end

---Attempt to find and require the plugin's main module with a .setup function
---@param pname string
---@param main string?
---@return table|nil
local function find_module(pname, main)
  if main then
    local ok, mod = pcall(require, main)
    if ok and type(mod) == 'table' and type(mod.setup) == 'function' then return mod end
  end

  if not pname then return nil end

  local candidates = {
    pname,
    pname:gsub('%.nvim$', ''),
    pname:gsub('%-nvim$', ''),
    pname:gsub('^nvim%-', ''),
    pname:gsub('^nvim%-', ''):gsub('%.nvim$', ''),
    (pname:gsub('%-', '_')),
    pname:gsub('%-.*', ''),
    pname:gsub('%d+$', ''),
  }

  for _, modname in ipairs(candidates) do
    local ok, mod = pcall(require, modname)
    if ok and type(mod) == 'table' and type(mod.setup) == 'function' then return mod end
  end

  return nil
end

---Modify hook called when a plugin specifies an `opts` field
---@param plugin lze.Plugin
---@return lze.Plugin
function M.modify(plugin)
  if plugin.opts == nil then return plugin end

  local orig_after = plugin.after
  local orig_config = plugin.config
  plugin.after = function(p)
    local opts = resolve_opts(p.opts, p)
    if opts ~= nil and p.setup ~= false then
      local name = p.name or p[1]
      local mod = find_module(name, p.main)
      if mod and type(mod.setup) == 'function' then
        if not mod.did_setup then mod.setup(opts) end
      end
    end

    if orig_after then orig_after(p) end
    if orig_config then orig_config(p, opts) end
  end

  return plugin
end

return M
