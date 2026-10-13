---@type lze.Handler
local M = {
  spec_field = 'load_before',
  set_lazy = true,
}

---@type table<string, string[]>
local states = {}

---Called when a plugin spec has `load_before`
---@param plugin lze.Plugin
---@return fun()?
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

  -- Record that `plugin.name` must load before `target`
  for _, target in ipairs(targets) do
    if states[target] == nil then
      states[target] = {}
    end
    if not vim.tbl_contains(states[target], plugin.name) then
      table.insert(states[target], plugin.name)
    end
  end
end

---Called before target plugin `name` is loaded.
---Triggers all plugins registered to load before it.
---@param name string
function M.before(name)
  if states[name] then
    local plugins = states[name]
    states[name] = nil
    require('lze').trigger_load(plugins)
  end
end

function M.cleanup()
  states = {}
end

return M
