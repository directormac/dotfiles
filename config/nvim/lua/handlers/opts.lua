---@type lze.Handler
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

  local candidates = {
    pname,
    pname:gsub('%.nvim$', ''),
    pname:gsub('%-nvim$', ''),
    pname:gsub('^nvim%-', ''),
    pname:gsub('^nvim%-', ''):gsub('%.nvim$', ''),
    (pname:gsub('%-', '_')),
    pname:gsub('%-.*', ''),
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
  plugin.after = function(p)
    local opts = resolve_opts(p.opts, p)
    if opts ~= nil and p.setup ~= false then
      local mod = find_module(p.name, p.main)
      if mod and type(mod.setup) == 'function' then
        if not mod.did_setup then mod.setup(opts) end
      end
    end

    if orig_after then orig_after(p) end
  end

  return plugin
end

return M
