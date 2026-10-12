local trigger_load = require('lz.n').trigger_load
local state = require('lz.n.handler.state').new()
local loading = {}

---@type lz.n.Handler
---@diagnostic disable-next-line: missing-fields
local M = {
  spec_field = 'on_require',
  lookup = state.lookup_plugin,
}

---@param plugin lz.n.Plugin
function M.add(plugin)
  if not plugin.on_require then return end
  state.insert(plugin)
end

M.del = state.del

---@param mod_path string
---@return boolean
local function call(mod_path)
  if loading[mod_path] then return false end
  loading[mod_path] = true

  local triggered_load = false
  state.each_pending(function(plugin)
    local on_req = plugin.on_require
    local mod_paths = type(on_req) == 'table' and on_req or { on_req }
    local has_mod = vim.iter(mod_paths):any(function(path) return vim.startswith(mod_path, path) end)
    if has_mod then
      trigger_load(plugin)
      triggered_load = true
    end
  end)

  loading[mod_path] = nil
  return triggered_load
end

M.call = call

function M.enable()
  local oldrequire = _G.require
  _G.require = function(mod_path)
    if package.loaded[mod_path] ~= nil then return oldrequire(mod_path) end
    if call(mod_path) == true then return oldrequire(mod_path) end
    return oldrequire(mod_path)
  end
end

return M
