---@type lze.Handler
---Custom `load_before` handler for `lze`.
---Allows a plugin to declare `load_before = { "target_plugin" }`, ensuring that this plugin
---is loaded immediately before the target plugin(s) are initialized.
---
---Semantics:
---  1. If any target plugin is already loaded when this spec is evaluated,
---     this plugin is triggered immediately.
---  2. Otherwise, this plugin is queued in `states[target]`. When `target` is about
---     to be loaded, `M.before(target)` triggers `lze.trigger_load()` for all queued plugins.
local M = {
  spec_field = 'load_before',
  set_lazy = true,
}

---@type table<string, string[]> Mapping of target plugin name -> list of plugins to load before it
local states = {}

---Called when a plugin spec defines `load_before`.
---@param plugin lze.Plugin
---@return fun()? Callback to trigger load immediately if target is already loaded
function M.add(plugin)
  local load_before = plugin.load_before
  if not load_before then return end

  ---@type string[]
  local targets = {}
  if type(load_before) == 'table' then
    targets = load_before
  elseif type(load_before) == 'string' then
    targets = { load_before }
  else
    return
  end

  local lze = require('lze')

  -- If any target plugin is already loaded, trigger this plugin immediately
  for _, target in ipairs(targets) do
    if lze.state(target) == false then
      return function()
        lze.trigger_load(plugin.name)
      end
    end
  end

  -- Record that `plugin.name` must load before each target plugin
  for _, target in ipairs(targets) do
    states[target] = states[target] or {}
    if not vim.tbl_contains(states[target], plugin.name) then
      table.insert(states[target], plugin.name)
    end
  end
end

---Called by `lze` immediately before target plugin `name` is loaded.
---Triggers all plugins registered to load before it.
---@param name string Target plugin name
function M.before(name)
  if states[name] then
    local plugins = states[name]
    states[name] = nil
    require('lze').trigger_load(plugins)
  end
end

---Cleanup internal state table
function M.cleanup()
  states = {}
end

return M
